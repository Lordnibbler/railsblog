require 'rails_helper'
require 'capybara/rails'

# stub logged in devise user w/ capybara
# @see https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
include Warden::Test::Helpers
Warden.test_mode!

CHROME_BINARY_PATH = ENV.fetch('CHROME_BIN', '/usr/bin/chromium')
HEADLESS_CHROME_BINARY_PATH = ENV.fetch('HEADLESS_CHROME_BIN', '/usr/bin/chromium-headless-shell')
CHROMEDRIVER_PATH = ENV.fetch('WEB_DRIVER_CHROME_DRIVER', '/usr/bin/chromedriver')

def chrome_options(binary_path: CHROME_BINARY_PATH)
  Selenium::WebDriver::Chrome::Options.new.tap do |options|
    options.binary = binary_path if File.exist?(binary_path)
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-background-networking')
    options.add_argument('--disable-extensions')
    options.add_argument('--disable-search-engine-choice-screen')
    options.add_argument('--remote-debugging-port=0')
    options.add_argument('--window-size=1400,1400')
  end
end

def chromedriver_service
  return unless File.exist?(CHROMEDRIVER_PATH)

  Selenium::WebDriver::Service.chrome(path: CHROMEDRIVER_PATH)
end

def chrome_driver(app, options:)
  driver_options = { browser: :chrome, options: options }
  service = chromedriver_service
  driver_options[:service] = service if service

  Capybara::Selenium::Driver.new(app, **driver_options)
end

Capybara.register_driver :chrome do |app|
  chrome_driver(app, options: chrome_options)
end

Capybara.register_driver :headless_chrome do |app|
  chrome_driver(
    app,
    options: chrome_options(binary_path: HEADLESS_CHROME_BINARY_PATH).tap { |options| options.add_argument('--headless') },
  )
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
