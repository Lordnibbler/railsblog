# renders static pages
class PagesController < ApplicationController
  include HighVoltage::StaticPage

  before_action do
    body_class 'static-page'
  end
end
