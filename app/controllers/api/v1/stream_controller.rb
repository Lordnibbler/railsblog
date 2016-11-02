#
# API returns aggregate stream data for "me feed"
#
class Api::V1::StreamController < ApiController
  def index
    render json: StreamService.all
  end

  # @example response body
  #   {
  #     "source": "instagram",
  #     "page": "1588941700",
  #     "posts": [
  #       {
  #         "source": "instagram",
  #         "key": "15889417100",
  #         "url_thumbnail": "https://scontent.cdninstagram.com/small.jpg",
  #         "url_original": "https://scontent.cdninstagram.com/big.jpg",
  #         "created_at": "1439016101",
  #         "url": "https://instagram.com/p/6HNobDCKGk/",
  #         "description": "This is a photo",
  #         "title": "My photo"
  #       }
  #     ]
  #   }
  def instagram
    posts = InstagramService.user_recent_media(max_id: params[:page])

    render json: {
      source: 'instagram',
      page: posts.last[:key], # provide to this API endpoint again for next page
      posts: posts
    }
  end

  # @example response body
  #   {
  #     "source": "flickr",
  #     "page": "2",
  #     "posts": [
  #       {
  #         "source": "flickr",
  #         "key": "15889417869",
  #         "url_thumbnail": "https://farm9.staticflickr.com/8580/15889417869_d3b603109b_n.jpg",
  #         "url_original": "https://farm9.staticflickr.com/8580/15889417869_d3b603109b_b.jpg",
  #         "created_at": "1419208668",
  #         "url": "https://www.flickr.com/photos/33668819@N03/15889417869",
  #         "description": "",
  #         "title": "IMG_6661"
  #       }
  #     ]
  #   }
  def flickr
    page = params[:page] ? params[:page].to_i + 1 : 2

    render json: {
      source: 'flickr',
      page: page, # provide to this API endpoint again for next page
      posts: FlickrService.get_photos(page: params[:page])
    }
  end
end
