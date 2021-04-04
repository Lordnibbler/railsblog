require 'rails_helper'
require 'capybara/rails'

# stub logged in devise user w/ capybara
# @see https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
include Warden::Test::Helpers
Warden.test_mode!

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu])
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# set to :chrome to see real browser open up
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

Capybara.server = :webrick
