require 'flickr'

# interface for fetching and caching photos from flickr API
class FlickrService
  PHOTOGRAPHY_CACHE_WARMED_KEY = 'photography_cache_warmed'.freeze

  class << self
    FLICKR_USER_ID = '33668819@N03'.freeze
    GET_PHOTOS_DEFAULT_OPTIONS = { user_id: FLICKR_USER_ID, per_page: 20, page: 1 }.freeze

    # fetches `pages` worth of photos from flickr and caches them
    # in a shuffled order since flickr does not allow sorting
    # in their API
    #
    # @param pages [Fixnum] the number of pages to fetch from flickr
    def warm_cache_shuffled(pages: nil)
      pages ||= total_pages
      Rails.logger.info("--->  Cache Warmer: total pages #{pages}")

      # we first fetch all photos in parallel using Concurrent::Future.
      # NOTE: we set shuffle to false in the get_photos method call,
      # because we want to shuffle all photos together, not just the photos on each page.
      futures = (1..pages).map do |page|
        Concurrent::Future.execute do
          Rails.logger.info("--->  Cache Warmer: fetching page #{page}")
          cache_key = self.generate_cache_key(
            user_id: GET_PHOTOS_DEFAULT_OPTIONS[:user_id],
            per_page: GET_PHOTOS_DEFAULT_OPTIONS[:per_page],
            page: page,
          )
          self.get_photos({ page: page }, cache_key, false)
        end
      end

      # We then shuffle the photos
      photos = futures.map(&:value).flatten.shuffle

      # We then cache the photos.
      photos.each_with_index do |photo, index|
        cache_key = self.generate_cache_key(
          user_id: GET_PHOTOS_DEFAULT_OPTIONS[:user_id],
          per_page: GET_PHOTOS_DEFAULT_OPTIONS[:per_page],
          page: index + 1,
        )
        Rails.cache.write(cache_key, photo, expires_in: 3.days)
      end
    end

    # @return [Array<Hash>, nil]
    # @param args [Hash]
    # @option args [Fixnum] :per_page
    # @option args [Fixnum] :page
    # @option args [Fixnum] :user_id
    # @param cache_key [String] a specific cache key to write the response from Flickr to
    def get_photos(args = {}, cache_key = nil, shuffle = false)
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)
      if cache_key.nil?
        cache_key = self.generate_cache_key(
          user_id: args[:user_id],
          per_page: args[:per_page],
          page: args[:page],
        )
      end

      # cache warmer runs daily in heroku scheduler, but we keep the cache
      # around for 3 days in case it does not run for some reason.
      Rails.cache.fetch cache_key, expires_in: 3.days do
        response = client.people.getPhotos(args)

        # Flickr is dumb and returns the final page of
        # results for any page after the final page. to
        # circumvent this we return nil if we've exceeded
        # the final page of results (response.pages)
        return nil if response.page > response.pages

        normalize(response:, shuffle:)
      end
    end

    # @return [Hash]
    def get_photo(photo_id)
      Rails.cache.fetch "flickr_photo_#{photo_id}", expires_in: 1.month do
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
    # @param shuffle [Boolean] should images be shuffled in the array before being returned
    # @return [Array<Hash>] normalize Flickr API response data into a useful array of hashes
    def normalize(response:, shuffle:)
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
      end.tap { |array| shuffle ? array.shuffle! : array }
    end

    def client
      # https://github.com/cyclotron3k/flickr#caching
      # load cache of methods available in flickr's api for test determinism
      # since api endpoints can be added/removed at random by flickr
      Flickr.cache = 'spec/factories/fixture_files/flickr-api.yml' if Rails.env.test?

      @client ||= Flickr.new(ENV.fetch('FLICKR_API_KEY', nil), ENV.fetch('FLICKR_SECRET', nil))
    end

    def generate_cache_key(user_id:, per_page:, page:)
      "flickr_photos_#{user_id}_#{per_page}_#{page}"
    end
  end
end
