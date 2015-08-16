#
# API returns aggregate stream data for "me feed"
# @example response body
#   [
#     {
#       "source": "instagram",
#       "url_thumbnail": "https://scontent.cdninstagram.com/small.jpg",
#       "url_original": "https://scontent.cdninstagram.com/big.jpg",
#       "created_at": "1439016101",
#       "url": "https://instagram.com/p/6HNobDCKGk/",
#       "description": "This is a photo",
#       "title": "My photo"}
#     }
#   ]
#
class Api::V1::StreamController < ApiController
  def index
    render json: StreamService.all
  end

  def instagram
    render json: InstagramService.all
  end

  def flickr
    render json: FlickrService.get_photos
  end
end
