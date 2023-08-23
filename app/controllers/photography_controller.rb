# renders photography page, fetching flickr photos from cache or
# directly from flickr if no cache available
class PhotographyController < ApplicationController
  before_action do
    #
    # masonry/photoswipe force some small gap on the right edge of the page
    # use overflow-x-hidden to hide it
    #
    body_class 'overflow-x-hidden photography'
  end

  def index
    @photos = FlickrService.get_photos_from_cache(page: index_params[:page] || 1) || []
  end

  private

  def index_params
    params.permit(:page)
  end
end
