require 'hashie'

# wrapper library for interacting with external APIs
class StreamService
  class << self
    # @return [Array<Hash>]
    def all
      InstagramStreamService.all
    end
  end
end

# wrapper for caching/fetching instagram media for
class InstagramStreamService
  class << self
    INSTAGRAM_USER_ID = 193210551

    #
    # @return [Array<Hash>]
    # @param id [Fixnum] the user's id on instagram
    #
    def all(id = INSTAGRAM_USER_ID)
      Rails.cache.fetch 'instagram_photos', expires_in: 5.minutes do
        client.user_recent_media(id, count: 100)
      end
    end

    def client
      Instagram.client(client_id: ENV['INSTAGRAM_CLIENT_ID'])
    end
  end
end
