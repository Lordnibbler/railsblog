# wrapper for caching/fetching instagram media for
class InstagramService
  class << self
    INSTAGRAM_USER_ID = 193210551

    #
    # @return [Array<Hash>]
    # @param user_id [Fixnum] the user's id on instagram
    # @param max_id [Fixnum] return media earlier than this max_id.
    # @param count [Fixnum] how many media objects to return
    #
    def user_recent_media(user_id: INSTAGRAM_USER_ID, count: 20, max_id: nil)
      Rails.cache.fetch "instagram_photos_#{max_id || 'newest'}", expires_in: 12.hours do
        munge(client.user_recent_media(user_id, count: count, max_id: max_id))
      end
    end

    private

    # @return [Array<Hash>] munged instagram API response into a useful array of hashes
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
          }.with_indifferent_access
        end
      end
    end

    def client
      @client ||= Instagram.client(client_id: ENV['INSTAGRAM_CLIENT_ID'])
    end
  end
end
