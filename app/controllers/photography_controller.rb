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
    @gallery_page = [index_params.fetch(:page, 1).to_i, 1].max
    @photos = FlickrService.get_photos(page: @gallery_page, seed: @gallery_seed, include_subjects: true)
    @photo_count = FlickrPhoto.count
    @gallery_has_more = @gallery_page * FlickrService::GET_PHOTOS_DEFAULT_OPTIONS[:per_page] < FlickrPhoto.count
  end

  private

  def index_params
    params.permit(:page, :seed)
  end
end
