#
# API returns aggregate stream data for "me feed"
#
class Api::V1::StreamController < ApiController
  def index
    render json: StreamService.all
  end
end
