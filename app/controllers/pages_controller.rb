# renders static pages
class PagesController < ApplicationController
  include HighVoltage::StaticPage

  before_action :set_body_class

  private

  def set_body_class
    body_class 'home'
  end
end
