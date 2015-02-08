class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  #
  # override {set_body_class} to customize the CSS class of the <body> tag
  #
  def set_body_class(name)
    @body_class = "#{name}-template"
  end
end
