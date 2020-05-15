class FlickrService
  class << self
    FlickRaw.api_key       = ENV['FLICKR_API_KEY']
    FlickRaw.shared_secret = ENV['FLICKR_SECRET']
    FLICKR_USER_ID         = '33668819@N03'.freeze
    GET_PHOTOS_DEFAULT_OPTIONS = { user_id: FLICKR_USER_ID, per_page: 20, page: 1 }.freeze

    def total_pages
      response = client.people.getPhotos(GET_PHOTOS_DEFAULT_OPTIONS.dup)
      response.pages
    end

    # fetches `pages` worth of photos from flickr and caches them
    # in a shuffled order since flickr does not allow sorting
    # in their API
    #
    # @param pages [Fixnum] the number of pages to fetch from flickr
    def warm_cache_shuffled(pages: nil)
      pages ||= total_pages
      puts "total pages #{pages}"
      pages_shuffled = (1..pages).to_a.shuffle
      pages_shuffled.each_with_index do |page, index|
        puts "warming cache page #{page} index #{index}"
        cache_key = self.generate_cache_key(
          user_id: GET_PHOTOS_DEFAULT_OPTIONS[:user_id],
          per_page: GET_PHOTOS_DEFAULT_OPTIONS[:per_page],
          page: page,
        )
        self.get_photos({ page: index + 1 }, cache_key, true)
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

      Rails.cache.fetch cache_key, expires_in: 1.day do
        response = client.people.getPhotos(args)

        # flickraw is dumb and returns the final page of
        # results for any page after the final page. to
        # circumvent this we return nil if we've exceeded
        # the final page of results (response.pages)
        return nil if response.page > response.pages

        normalize(response: response, shuffle: shuffle)
      end
    end

    # @return [Hash]
    def get_photo(photo_id)
      Rails.cache.fetch "flickr_photo_#{photo_id}", expires_in: 1.month do
        client.photos.getInfo(photo_id: photo_id)
      end
    end

    private

    # @param response [FlickRaw::Response]
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
            url: FlickRaw.url_photopage(photo),
            description: get_photo_response.description,
            title: get_photo_response.title,
          }
        end
      end.tap { |array| shuffle ? array.shuffle! : array }
    end

    def client
      @client ||= FlickRaw::Flickr.new
    end

    def generate_cache_key(user_id:, per_page:, page:)
      "flickr_photos_#{user_id}_#{per_page}_#{page}"
    end
  end
end
