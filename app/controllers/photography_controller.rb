class PhotographyController < ApplicationController
  def index
    ap '*' * 50
    ap photography_params
    # params[:page] ||= 1
    @photos = FlickrService.get_photos(page: photography_params[:page])
  end

  private

  def photography_params
    params.permit(:page)
  end
end