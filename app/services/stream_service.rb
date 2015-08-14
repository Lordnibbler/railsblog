# wrapper library for interacting with external APIs
class StreamService
  class << self
    # @return [Array<Hash>]
    def all
      InstagramService.all + FlickrService.get_photos
    end
  end
end
