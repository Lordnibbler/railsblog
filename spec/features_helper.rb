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

# set CAPYBARA_DRIVER=chrome for a visible browser when debugging
Capybara.default_driver = ENV.fetch('CAPYBARA_DRIVER', 'rack_test').to_sym
Capybara.javascript_driver = ENV.fetch('CAPYBARA_JS_DRIVER', 'headless_chrome').to_sym

if %i[chrome headless_chrome].include?(Capybara.default_driver)
  Capybara.javascript_driver = Capybara.default_driver
end

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
    return unless js_examples_present?
    return if self.already_built

    run_assets
  end

  def self.js_examples_present?
    examples = RSpec.world.filtered_examples.values.flatten
    examples.any? { |example| example.metadata[:js] }
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    AssetsTestBuild.run_assets_if_necessary
  end

end
