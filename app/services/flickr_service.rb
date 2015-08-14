require 'hashie'

class FlickrService
  class << self
    FlickRaw.api_key = ENV['FLICKR_API_KEY']
    FlickRaw.shared_secret = ENV['FLICKR_SECRET']
    FLICKR_USER_ID = '33668819@N03'

    SIZE_SUFFIXES = {
      small_square: 's'.freeze, # 75x75
      large_square: 'q'.freeze, # 150x150
      thumbnail:    't'.freeze, # 100 on longest side
      small_240:    'm'.freeze, # 240 on longest side
	small_320:    'n'.freeze, # 320 on longest side
      medium_500:   '-'.freeze, # 500 on longest side
      medium_640:   'z'.freeze, # 640 on longest side
      medium_800:   'c'.freeze, # 800 on longest side
      large_1024:   'b'.freeze, # 1024 on longest side
      large_1600:   'h'.freeze, # 1600 on longest side
      large_2048:   'k'.freeze, # 2048 on longest side
      original:     'o'.freeze  # either a jpg, gif or png, depending on source format
    }

    # @return [Array<Hash>]
    def get_photos(args = { user_id: FLICKR_USER_ID, per_page: 100, page: 1 })
      Rails.cache.fetch 'flickr_photos', expires_in: 5.minutes do
        munge(flickr.people.getPhotos(args))
      end
    end

    private

    # @return [Array<Hash>] munged Flickr API response data into a useful array of hashes
    def munge(response)
      [].tap do |array|
        response.each do |photo|
          array << {
            source:        'flickr',
            key:           SecureRandom.hex(3),
            url_thumbnail: generate_img_url(photo, SIZE_SUFFIXES[:small_320]),
            url_original:  generate_img_url(photo, SIZE_SUFFIXES[:large_1024]),
            created_at:    '',
            url:           generate_url(photo),
            description:   '',
            title:         ''
          }
        end
      end
    end

    # @see https://www.flickr.com/services/api/misc.urls.html
    def generate_img_url(photo, size_suffix)
      "https://farm#{photo['farm']}.staticflickr.com/#{photo['server']}/#{photo['id']}_#{photo['secret']}_#{size_suffix}.jpg"
    end

    def generate_url(photo)
      "https://www.flickr.com/photos/#{FLICKR_USER_ID}/#{photo['id']}"
    end
  end
end
