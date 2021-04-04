# renders photography page, fetching flickr photos from cache or
# directly from flickr if no cache available
class PhotographyController < ApplicationController
  before_action :set_body_class

  def index
    @photos = FlickrService.get_photos(page: index_params[:page] || 1) || []
  end

  private

  def index_params
    params.permit(:page)
  end

  def set_body_class
    body_class 'photography'
  end
end
