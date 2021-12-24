# renders static pages
class PagesController < ApplicationController
  include HighVoltage::StaticPage

  before_action do
    set_body_class 'static-page'
  end
end
