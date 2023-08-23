require 'flickr'

# interface for fetching and caching photos from flickr API
class FlickrService
  # This class is responsible for fetching and caching photos from Flickr API
  # It provides methods to warm up the cache, fetch photos from cache or directly from Flickr
  # and also to check if the cache is warmed up
  #
  # Example usage:
  #   FlickrService.warm_cache_shuffled
  #
  # Note: This class uses Rails.cache for caching the photos and it expects the cache to be warmed up
  #       daily using Heroku scheduler. The cache is kept for 3 days.
  #
  # Note: This class uses Flickr API to fetch the photos and due to the instability of the API,
  #       it implements a retry logic in case of connection failures.
  PHOTOGRAPHY_CACHE_WARMED_KEY = 'photography_cache_warmed'.freeze
  FLICKR_USER_ID = '33668819@N03'.freeze
  GET_PHOTOS_DEFAULT_OPTIONS = { user_id: FLICKR_USER_ID, per_page: 20, page: 1 }.freeze

  class << self
    def logger
      logger ||= begin
        logger = Logger.new($stdout)
        logger.formatter = proc do |severity, datetime, progname, msg|
          date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
          "---> [#{date_format}] #{severity} (#{progname}): FlickrService: #{msg}\n"
        end
        logger
      end

      logger
    end

    def warm_cache_shuffled(pages: nil)
      pages ||= total_pages
      logger.info("Concurrently fetching #{pages} total pages of photos from Flickr")

      photos = fetch_and_randomize_photos(pages)

      # 3. Cache the individual photos
      # example cache key: flickr_photo/49822914933
      cache_photos(photos)

      # 4. Cache photos in batches of `per_page` size
      # example cache key: flickr_photos/33668819@N03_20_1
      logger.info("Writing #{pages} pages of photos to cache")
      cache_photos_in_batches(photos, pages)

      logger.info("Wrote #{photos.count} photos to cache")
      logger.info("Example photo cache key: #{self.generate_photo_cache_key(photo_id: photos[0][:key])}")
      logger.info("Example batch cache key: #{self.generate_page_cache_key(user_id: FLICKR_USER_ID, page: 1, per_page: 20)}")
      logger.info('Done')
    end

    def get_photos_from_flickr(args = {})
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)
      response = client.people.getPhotos(args)
      return nil if response.page > response.pages

      normalize(response:)
    end

    def get_photos_from_cache(args = {}, cache_key = nil)
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)
      logger.info(args)
      cache_key ||= self.generate_page_cache_key(
        user_id: args[:user_id],
        per_page: args[:per_page],
        page: args[:page],
      )
      Rails.cache.fetch(cache_key, expires_in: 3.days) { get_photos_from_flickr(args) }
    end

    def get_photo(photo_id)
      Rails.cache.fetch(generate_photo_cache_key(photo_id:), expires_in: 1.month) { client.photos.getInfo(photo_id:) }
    end

    def cache_warmed?
      Rails.cache.fetch(PHOTOGRAPHY_CACHE_WARMED_KEY)
    end

    private

    def total_pages
      response = client.people.getPhotos(GET_PHOTOS_DEFAULT_OPTIONS.dup)
      response.pages
    end

    def fetch_and_randomize_photos(pages)
      futures = (1..pages).map { |page| fetch_photos_future(page) }
      futures.map(&:value).flatten.compact.shuffle
    end

    def fetch_photos_future(page)
      Concurrent::Future.execute { fetch_photos_with_retry(page) }
    end

    def fetch_photos_with_retry(page, attempts = 0)
      logger.info("fetching page #{page} from flickr on attempt #{attempts}")
      get_photos_from_flickr(page:)
    rescue Errno::ECONNRESET => e
      retry_or_raise_error(page, attempts, e)
    end

    def retry_or_raise_error(page, attempts, error)
      if attempts >= 5
        logger.error("exhausted retries for page #{page}")
        raise error
      end

      logger.info("future for page #{page} retrying")
      fetch_photos_with_retry(page, attempts + 1)
    end

    def cache_photos(photos)
      photos.each do |photo|
        cache_key = generate_photo_cache_key(photo_id: photo[:key])
        Rails.cache.write(cache_key, photo, expires_in: 3.days)
      end
    end

    def cache_photos_in_batches(photos, pages)
      photos_in_batches = photos.each_slice(GET_PHOTOS_DEFAULT_OPTIONS[:per_page]).to_a
      photos_in_batches.each_with_index do |photo_batch, index|
        cache_key = generate_page_cache_key(user_id: GET_PHOTOS_DEFAULT_OPTIONS[:user_id], per_page: GET_PHOTOS_DEFAULT_OPTIONS[:per_page], page: index + 1)
        Rails.cache.write(cache_key, photo_batch, expires_in: 3.days)
      end
    end

    def normalize(response:)
      response.map { |photo| normalize_photo(photo) }
    end

    def normalize_photo(photo)
      get_photo_response = get_photo(photo.id)
      sizes = client.photos.getSizes(photo_id: photo.id)
      {
        source: 'flickr',
        key: photo.id,
        photo_thumbnail: get_photo_size(sizes, 'Thumbnail'),
        photo_small: get_photo_size(sizes, 'Small 400'),
        photo_medium: get_photo_size(sizes, 'Medium 800'),
        photo_large: get_photo_size(sizes, 'Large 1600'),
        created_at: get_photo_response.dateuploaded,
        url: Flickr.url_photopage(photo),
        description: get_photo_response.description,
        title: get_photo_response.title,
      }
    end

    def get_photo_size(sizes, label)
      size = sizes.find { |s| s.label == label }
      { url: size.source, width: size.width, height: size.height }
    end

    def client
      Flickr.cache = 'spec/factories/fixture_files/flickr-api.yml' if Rails.env.test?
      @client ||= Flickr.new(ENV.fetch('FLICKR_API_KEY', nil), ENV.fetch('FLICKR_SECRET', nil))
    end

    def generate_page_cache_key(user_id:, per_page:, page:)
      "flickr_photos/#{user_id}_#{per_page}_#{page}"
    end

    def generate_photo_cache_key(photo_id:)
      "flickr_photo/#{photo_id}"
    end
  end
end
