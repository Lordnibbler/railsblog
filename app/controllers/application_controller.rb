#
# superclass for all Rails controllers to extend
#
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_meta_tags_title

  private

  #
  # set the default string for the site's meta tags
  #
  def set_meta_tags_title
    set_meta_tags site: 'benradler.com'
  end

  #
  # @note invoke body_class in subclass to customize the CSS class of the <body> tag
  # sets the body_class ivar to a class based on the {name} attribute; used in CSS
  #
  def body_class(name)
    @body_class = "#{name}-template"
  end
end
