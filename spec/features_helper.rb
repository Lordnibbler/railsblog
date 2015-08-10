require 'rails_helper'
require 'capybara/rails'
require 'capybara/poltergeist'

# stub logged in devise user w/ capybara
# @see https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
include Warden::Test::Helpers
Warden.test_mode!

# use phantomjs headless driver
Capybara.javascript_driver = :poltergeist
