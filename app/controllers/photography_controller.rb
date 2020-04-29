class PhotographyController < ApplicationController
  before_action :set_body_class

  def index
    @photos = FlickrService.get_photos(page: photography_params[:page] || 1) || []
  end

  private

  def photography_params
    params.permit(:page)
  end

  def set_body_class
    body_class 'photography'
  end
end