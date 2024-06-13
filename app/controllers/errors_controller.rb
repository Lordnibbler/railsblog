# render jazzy custom error pages rather than stinky default ones!
# @see http://easyactiverecord.com/blog/2014/08/19/redirecting-to-custom-404-and-500-pages-in-rails/
class ErrorsController < ApplicationController
  def file_not_found
    render status: :not_found
  end

  def unprocessable_entity
    render status: :unprocessable_content
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
