# render jazzy custom error pages rather than stinky default ones!
# @see http://easyactiverecord.com/blog/2014/08/19/redirecting-to-custom-404-and-500-pages-in-rails/
class ErrorsController < ApplicationController
  def file_not_found
    render status: 404
  end

  def unprocessable_entity
    render status: 422
  end

  def internal_server_error
    render status: 500
  end
end
