require 'flickr'

# Interface for synchronizing Flickr photos into the local database.
# rubocop:disable Metrics/ClassLength
class FlickrService
  # Fetches photos from Flickr for a scheduled database refresh and serves the
  # resulting local catalog to controllers.
  #
  # Example usage:
  #   FlickrService.sync_photos
  #
  # Note: This class uses Flickr API to fetch the photos and due to the instability of the API,
  #       it implements a retry logic in case of connection failures.
  FLICKR_USER_ID = '33668819@N03'.freeze
  GET_PHOTOS_DEFAULT_OPTIONS = { user_id: FLICKR_USER_ID, per_page: 20, page: 1 }.freeze

  class << self
    # @return [Logger] logger instance
    def logger
      @logger ||= begin
        logger = Logger.new($stdout)
        logger.level = Logger::WARN if Rails.env.test?
        logger.formatter = proc do |severity, datetime, progname, msg|
          date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
          "---> [#{date_format}] #{severity} (#{progname}): FlickrService: #{msg}\n"
        end
        logger
      end
    end

    # Refreshes the local photo catalog from Flickr. Existing rows remain intact
    # if fetching fails, and all database changes are committed atomically.
    # @param pages [Integer] number of pages to fetch from Flickr
    # @return [void]
    def sync_photos(pages: nil)
      started_at = monotonic_time
      pages ||= timed('fetching total Flickr pages') { total_pages }
      logger.info("Concurrently fetching #{pages} total pages of photos from Flickr")

      photos = timed("fetching and randomizing #{pages} pages") { fetch_and_randomize_photos(pages) }

      timed("writing #{photos.count} photos to the database") { replace_photos(photos) }
      logger.info("Wrote #{photos.count} photos to the database")
      logger.info("Done in #{elapsed_since(started_at)}s")
    end

    # Fetches photos from Flickr
    # @param args [Hash] arguments to pass to the Flickr API
    # @return [Array<Hash>, nil] array of photo data or nil if the requested page is greater than total pages
    def get_photos_from_flickr(args = {})
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)
      response = client.people.getPhotos(args)
      return nil if response.page > response.pages

      normalize(response:)
    end

    # Returns one stable, pre-shuffled page from the local catalog.
    def get_photos(args = {})
      page = [args.fetch(:page, 1).to_i, 1].max
      FlickrPhoto.order(:display_position)
                 .offset((page - 1) * GET_PHOTOS_DEFAULT_OPTIONS[:per_page])
                 .limit(GET_PHOTOS_DEFAULT_OPTIONS[:per_page])
                 .map(&:as_stream_item)
    end

    private

    def total_pages
      response = client.people.getPhotos(GET_PHOTOS_DEFAULT_OPTIONS.dup)
      response.pages
    end

    # Fetches and randomizes photos
    # @param pages [Integer] number of pages to fetch from Flickr
    # @return [Array<Hash>] array of randomized photo data
    def fetch_and_randomize_photos(pages)
      concurrency = Integer(ENV.fetch('FLICKR_CACHE_WARMER_CONCURRENCY', 2))
      logger.info("fetching Flickr pages with concurrency #{concurrency}")

      (1..pages).each_slice(concurrency).flat_map do |page_batch|
        futures = page_batch.map { |page| [page, fetch_photos_future(page)] }
        futures.flat_map do |page, future|
          future.value!
        rescue StandardError => e
          logger.error("failed to fetch page #{page}: #{e.class}: #{e.message}")
          raise
        end
      end.shuffle
    end

    def fetch_photos_future(page)
      Concurrent::Future.execute { fetch_photos_with_retry(page) }
    end

    # Fetches photos with retry logic in case of connection failures
    # @param page [Integer] page number to fetch from Flickr
    # @param attempts [Integer] number of attempts made to fetch photos
    # @return [Array<Hash>, nil] array of photo data or nil if an error occurs
    def fetch_photos_with_retry(page, attempts = 0)
      started_at = monotonic_time
      logger.info("fetching page #{page} from flickr on attempt #{attempts}")
      get_photos_from_flickr(page:).tap do |photos|
        logger.info("fetched page #{page} with #{photos&.count || 0} photos in #{elapsed_since(started_at)}s")
      end
    rescue StandardError => e
      raise unless retryable_flickr_error?(e)

      retry_or_raise_error(page, attempts, e)
    end

    def retry_or_raise_error(page, attempts, error)
      max_attempts = Integer(ENV.fetch('FLICKR_CACHE_WARMER_RETRIES', 5))
      if attempts >= max_attempts
        logger.error("exhausted retries for page #{page}: #{error.class}: #{error.message}")
        raise error
      end

      logger.info("future for page #{page} retrying after #{error.class}: #{error.message}")
      fetch_photos_with_retry(page, attempts + 1)
    end

    def retryable_flickr_error?(error)
      retryable_errors = [
        Errno::ECONNRESET,
        EOFError,
        JSON::ParserError,
        Net::OpenTimeout,
        Net::ReadTimeout,
        Timeout::Error,
      ]

      retryable_errors.any? { |error_class| error.is_a?(error_class) } || flickr_service_unavailable?(error)
    end

    def flickr_service_unavailable?(error)
      error.is_a?(Flickr::FailedResponse) && error.message.match?(/not currently available|unavailable|temporarily/i)
    end

    def replace_photos(photos)
      now = Time.current
      rows = photos.map.with_index(1) do |photo, position|
        {
          flickr_id: photo.fetch(:key).to_s, photo_data: photo, display_position: position,
          created_at: now, updated_at: now,
        }
      end

      FlickrPhoto.transaction do
        # Avoid transient uniqueness conflicts while assigning the new ordering.
        FlickrPhoto.update_all('display_position = display_position * -1')
        FlickrPhoto.upsert_all(rows, unique_by: :flickr_id)
        FlickrPhoto.where.not(flickr_id: rows.pluck(:flickr_id)).delete_all
      end
    end

    # Normalizes the response from Flickr API to a hash usable in the UI
    # @param response [Array<Hash>] response from Flickr API
    # @return [Array<Hash>] array of normalized photo data
    def normalize(response:)
      logger.info("normalizing #{response.count} photos")
      response.map.with_index(1) do |photo, index|
        timed("normalizing photo #{index}/#{response.count} id=#{photo.id}") { normalize_photo(photo) }
      end
    end

    # Normalizes a single photo response from Flickr
    # @param photo [Hash] photo data to normalize
    # @return [Hash] normalized photo data
    def normalize_photo(photo)
      get_photo_response = timed("fetching info for photo #{photo.id}") { client.photos.getInfo(photo_id: photo.id) }
      sizes = timed("fetching sizes for photo #{photo.id}") { client.photos.getSizes(photo_id: photo.id) }
      {
        source: 'flickr',
        key: photo.id,
        photo_thumbnail: get_photo_size(sizes, 'Thumbnail'),
        photo_small: get_photo_size(sizes, 'Small 400'),
        photo_medium: get_photo_size(sizes, 'Medium 800'),
        photo_large: get_photo_size(sizes, 'Large'), # 'Large 1600' is no longer available with free flickr plan
        created_at: get_photo_response.dateuploaded,
        url: Flickr.url_photopage(photo),
        description: get_photo_response.description,
        title: get_photo_response.title,
      }
    end

    # Fetches a photo size by its label
    # @param sizes [Array<Hash>] array of photo sizes
    # @param label [String] label of the photo size to fetch
    # @return [Hash] photo size data
    def get_photo_size(sizes, label)
      size = sizes.find { |s| s.label == label }
      { url: size.source, width: size.width, height: size.height }
    end

    # @return [Flickr] Flickr client instance
    def client
      Flickr.cache = 'spec/factories/fixture_files/flickr-api.yml' if Rails.env.test?
      @client ||= Flickr.new(ENV.fetch('FLICKR_API_KEY', nil), ENV.fetch('FLICKR_SECRET', nil))
    end

    def timed(label)
      started_at = monotonic_time
      logger.info("#{label} started")
      yield.tap { logger.info("#{label} finished in #{elapsed_since(started_at)}s") }
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def elapsed_since(started_at)
      (monotonic_time - started_at).round(2)
    end
  end
end
# rubocop:enable Metrics/ClassLength
