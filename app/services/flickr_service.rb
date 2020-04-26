class FlickrService
  class << self
    FlickRaw.api_key       = ENV['FLICKR_API_KEY']
    FlickRaw.shared_secret = ENV['FLICKR_SECRET']
    FLICKR_USER_ID         = '33668819@N03'.freeze
    GET_PHOTOS_DEFAULT_OPTIONS = { user_id: FLICKR_USER_ID, per_page: 20, page: 1 }.freeze

    # @return [Array<Hash>]
    # @param args [Hash]
    # @option args [Fixnum] :per_page
    # @option args [Fixnum] :page
    # @option args [Fixnum] :user_id
    def get_photos(args = {})
      args = GET_PHOTOS_DEFAULT_OPTIONS.merge(args)
      key  = "flickr_photos_#{args[:user_id]}_#{args[:per_page]}_#{args[:page]}"
      resp = client.people.getPhotos(args)

      # flickraw is dumb and returns the final page of results for any page after the final page
      return nil if resp.page > resp.pages

      Rails.cache.fetch key, expires_in: 5.minutes do
        munge(resp)
      end
    end

    # @return [Hash]
    def get_photo(photo_id)
      Rails.cache.fetch "flickr_photo_#{photo_id}", expires_in: 1.year do
        client.photos.getInfo(photo_id: photo_id)
      end
    end

    private

    # @return [Array<Hash>] munged Flickr API response data into a useful array of hashes
    def munge(response)
      [].tap do |array|
        response.each do |photo|
          get_photo_response = get_photo(photo.id)

          sizes = client.photos.getSizes(photo_id: photo.id)
          large_size = sizes.find { |s| s.label == 'Large 1600' }
          thumbnail_size = sizes.find { |s| s.label == 'Thumbnail' }

          array << {
            source: 'flickr',
            key: photo.id,
            photo_thumbnail: {
              url: FlickRaw.url_n(photo),
              width: thumbnail_size.width,
              height: thumbnail_size.height,
            },
            photo_large: {
              url: FlickRaw.url_b(photo),
              width: large_size.width,
              height: large_size.height,
            },
            created_at: get_photo_response.dateuploaded,
            url: FlickRaw.url_photopage(photo),
            description: get_photo_response.description,
            title: get_photo_response.title,
          }
        end
      end
    end

    def client
      @client ||= FlickRaw::Flickr.new
    end
  end
end
