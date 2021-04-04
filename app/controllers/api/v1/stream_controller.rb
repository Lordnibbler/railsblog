#
# API for cached photos from Flickr
#
class Api::V1::StreamController < ApiController
  def index
    render json: FlickrService.get_photos(page: params[:page])
  end

  # @example response body
  #   {
  #     "source": "flickr",
  #     "page": "2",
  #     "posts": [
  #       {
  #         "source": "flickr",
  #         "key": "15889417869",
  #         "photo_thumbnail": {
  #           url: "https://farm9.staticflickr.com/8580/15889417869_d3b603109b_n.jpg",
  #           width: 100,
  #           height: 67,
  #         },
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
      posts: FlickrService.get_photos(page: params[:page]),
    }
  end
end
