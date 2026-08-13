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
    @gallery_seed = index_params[:seed].presence || Random.new_seed
    @photos = FlickrService.get_photos(page: index_params[:page] || 1, seed: @gallery_seed)
  end

  private

  def index_params
    params.permit(:page, :seed)
  end
end
