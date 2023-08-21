require 'flickr'

# interface for fetching and caching photos from flickr API
class FlickrService
  PHOTOGRAPHY_CACHE_WARMED_KEY = 'photography_cache_warmed'.freeze

  class << self
    FLICKR_USER_ID = '33668819@N03'.freeze
    GET_PHOTOS_DEFAULT_OPTIONS = { user_id: FLICKR_USER_ID, per_page: 20, page: 1 }.freeze

    # fetches `pages` (or total_pages) worth of photos from flickr, store in array in memory
    # fetch and cache each photo details in Rails.cache
    # cache pages of photos in batches of per_page
    #
    # @param pages [Fixnum] the number of pages to fetch from flickr
    def warm_cache_shuffled(pages: nil)

      pages ||= total_pages
      Rails.logger.info("--->  Cache Warmer: total pages #{pages}")

      # 1. Create futures to fetch all pages of photos in parallel
      # using Concurrent::Future with retry logic
      futures = (1..pages).map do |page|
        Concurrent::Future.execute do
          Rails.logger.info("--->  Cache Warmer: fetching page #{page} from flickr")
          begin
            attempts = 0
            self.get_photos_from_flickr(page:)
          rescue Errno::ECONNRESET => e
            # NOTE: we may need to retry because flickr API is trash and randomly has connection failures
            Rails.logger.warn("--->  Cache Warmer: future for page #{page} got error '#{e}' with #{attempts} retries so far")
            if attempts < 5
              attempts += 1
              Rails.logger.info("---> Cache Warmer: future for page #{page} retrying")
              retry
            end
            Rails.logger.error("---> Cache Warmer: future for page #{page} failed after #{attempts} retries")
            raise e
          end
        end
      end

      # 2. Execute all futures concurrently, fetching all photos and randomizing their order
      photos = futures.map(&:value).flatten.compact.shuffle
      Rails.logger.info("--->  Cache Warmer: randomizing order of #{photos.count} photos")

      # 3. Cache the individual photos
      # example cache key: flickr_photo/49822914933
      Rails.logger.info("--->  Cache Warmer: Writing #{photos.count} photos to cache, example cache key: #{self.generate_photo_cache_key(photo_id: photos[0][:key])}")
      photos.each do |photo|
        cache_key = self.generate_photo_cache_key(photo_id: photo[:key])
        Rails.cache.write(cache_key, photo, expires_in: 3.days)
      end

      # 4. Cache photos in batches of `per_page` size
      # example cache key: flickr_photos/33668819@N03_20_1
      Rails.logger.info("--->  Cache Warmer: Writing #{pages} pages of photos to cache")
      photos_in_batches = photos.each_slice(GET_PHOTOS_DEFAULT_OPTIONS[:per_page]).to_a
      photos_in_batches.each_with_index do |photo_batch, index|
        cache_key = self.generate_page_cache_key(
          user_id: GET_PHOTOS_DEFAULT_OPTIONS[:user_id],
          per_page: GET_PHOTOS_DEFAULT_OPTIONS[:per_page],
          page: index + 1,
        )
        Rails.logger.info("--->  Cache Warmer: Writing #{photo_batch.count} photos to cache key #{cache_key}")
        Rails.cache.write(cache_key, photo_batch, expires_in: 3.days)
      end

      Rails.logger.info('--->  Cache Warmer: Done')
    end

    # @return [Array<Hash>, nil]
    # @param args [Hash]
    # @option args [Fixnum] :per_page
    # @option args [Fixnum] :page
    # @option args [Fixnum] :user_id
    # @param cache_key [String] a specific cache key to write the response from Flickr to
    #    get_photos_from_flickr (what we call get_photos today)
    def get_photos_from_flickr(args = {})
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)

      response = client.people.getPhotos(args)

      # Flickr is dumb and returns the final page of
      # results for any page after the final page. to
      # circumvent this we return nil if we've exceeded
      # the final page of results (response.pages)
      return nil if response.page > response.pages

      # normalize the shape of the raw response from flickr API to something useful in our UI
      normalize(response:)
    end

    # controller will call get_photos_from_cache. if returns nil, then call get_photos_from_flickr. otherwise return result from cache.
    # get_photos_from_cache can pass get_photos_from_flickr as the cache miss block; then warm_cache_shuffled can also call get_photos_from_flickr.
    def get_photos_from_cache(args = {}, cache_key = nil)
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)
      if cache_key.nil?
        cache_key = self.generate_page_cache_key(
          user_id: args[:user_id],
          per_page: args[:per_page],
          page: args[:page],
        )
      end

      # cache warmer runs daily in heroku scheduler, but we keep the cache
      # around for 3 days in case it does not run for some reason.
      # block is executed if cache miss
      Rails.cache.fetch(cache_key, expires_in: 3.days) do
        get_photos_from_flickr(args)
      end
    end

    # @return [Hash]
    # the raw photo object from flickr's api
    def get_photo(photo_id)
      Rails.cache.fetch(self.generate_photo_cache_key(photo_id:), expires_in: 1.month) do
        client.photos.getInfo(photo_id:)
      end
    end

    def cache_warmed?
      Rails.cache.fetch(PHOTOGRAPHY_CACHE_WARMED_KEY)
    end

    private

    # @return [Fixnum] total number of pages on user's photostream
    def total_pages
      response = client.people.getPhotos(GET_PHOTOS_DEFAULT_OPTIONS.dup)
      response.pages
    end

    # @param response [Flickr::Response]
    # @return [Array<Hash>] normalize Flickr API response data into a useful array of hashes
    def normalize(response:)
      [].tap do |array|
        response.each do |photo|
          get_photo_response = get_photo(photo.id)

          sizes = client.photos.getSizes(photo_id: photo.id)
          large_size     = sizes.find { |s| s.label == 'Large 1600' }
          medium_size    = sizes.find { |s| s.label == 'Medium 800' }
          small_size     = sizes.find { |s| s.label == 'Small 400' }
          thumbnail_size = sizes.find { |s| s.label == 'Thumbnail' }

          array << {
            source: 'flickr',
            key: photo.id,
            photo_thumbnail: {
              url: thumbnail_size.source,
              width: thumbnail_size.width,
              height: thumbnail_size.height,
            },
            photo_small: {
              url: small_size.source,
              width: small_size.width,
              height: small_size.height,
            },
            photo_medium: {
              url: medium_size.source,
              width: medium_size.width,
              height: medium_size.height,
            },
            photo_large: {
              url: large_size.source,
              width: large_size.width,
              height: large_size.height,
            },
            created_at: get_photo_response.dateuploaded,
            url: Flickr.url_photopage(photo),
            description: get_photo_response.description,
            title: get_photo_response.title,
          }
        end
      end
    end

    def client
      # https://github.com/cyclotron3k/flickr#caching
      # load cache of methods available in flickr's api for test determinism
      # since api endpoints can be added/removed at random by flickr
      Flickr.cache = 'spec/factories/fixture_files/flickr-api.yml' if Rails.env.test?

      @client ||= Flickr.new(ENV.fetch('FLICKR_API_KEY', nil), ENV.fetch('FLICKR_SECRET', nil))
    end

    # generate a cache key for each cached page of photos
    def generate_page_cache_key(user_id:, per_page:, page:)
      "flickr_photos/#{user_id}_#{per_page}_#{page}"
    end

    # generate a cache key for an individual photo
    def generate_photo_cache_key(photo_id:)
      "flickr_photo/#{photo_id}"
    end
  end
end
