# wrapper for caching/fetching instagram media for
class InstagramService
  class << self
    INSTAGRAM_USER_ID = 193210551

    #
    # @return [Array<Hash>]
    # @param id [Fixnum] the user's id on instagram
    #
    def all(id: INSTAGRAM_USER_ID, max_id: nil)
      Rails.cache.fetch 'instagram_photos', expires_in: 12.hours do
        munge(client.user_recent_media(id, count: 100, max_id: max_id))
      end
    end

    private

    # munges the instagram API response into a useful array of hashes
    def munge(response)
      [].tap do |array|
        response.each do |media|
          array << {
            source:        'instagram',
            key:           media.id,
            url_thumbnail: media.images.low_resolution.url,
            url_original:  media.images.standard_resolution.url,
            created_at:    media.created_time,
            url:           media.link,
            description:   media.caption.text,
            title:         ''
          }
        end
      end
    end

    def client
      Instagram.client(client_id: ENV['INSTAGRAM_CLIENT_ID'])
    end
  end
end
