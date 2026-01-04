require 'rails_helper'
require 'capybara/rails'

# stub logged in devise user w/ capybara
# @see https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
include Warden::Test::Helpers
Warden.test_mode!

# Webdrivers::Chromedriver.required_version = "118.0.5993.70"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu])
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# set to :chrome to see real browser open up
# Capybara.default_driver = :chrome
# Capybara.javascript_driver = :chrome
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

Capybara.server = :webrick


# asset bundles are not automatically compiled before tests run
module AssetsTestBuild
  class << self
    attr_accessor :already_built
  end

  def self.run_assets
    puts "running asset build for tests"
    puts `which node`
    puts `node --version`
    shell = ENV.fetch("SHELL", "/bin/bash")
    success = system({ "RAILS_ENV" => "test" }, shell, "-ic", "bin/rails assets:precompile")
    raise "asset build failed" unless success
    self.already_built = true
  end

  def self.run_assets_if_necessary
    return if ENV['CIRCLECI'] # assets are explicitly compiled in the build step of circleci
    return if self.already_built

    run_assets
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    AssetsTestBuild.run_assets_if_necessary
  end

end
