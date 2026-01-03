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


# asset bundles not automatically compiling before tests run
module AssetsTestBuild
  TS_FILE = Rails.root.join("tmp", "assets-spec-timestamp")
  class << self
    attr_accessor :already_built
  end

  def self.run_assets
    puts "running asset build for tests"
    puts `which node`
    puts `node --version`
    shell = ENV.fetch("SHELL", "/bin/bash")
    success = system({ "RAILS_ENV" => "test" }, shell, "-ic", "yarn build")
    raise "asset build failed" unless success
    self.already_built = true
    FileUtils.mkdir_p(Rails.root.join("tmp"))
    File.open(TS_FILE, "w") { |f| f.write(Time.now.utc.to_i) }
  end

  def self.run_assets_if_necessary
    return if ENV['CIRCLECI'] # assets are explicitly compiled in the build step of circleci
    return if self.already_built

    run_assets if timestamp_outdated?
  end

  def self.timestamp_outdated?
    return true if !File.exist?(TS_FILE)

    current = current_bundle_timestamp(TS_FILE)

    return true if !current

    expected = Dir[Rails.root.join("app", "javascript", "**", "*")].map do |f|
      File.mtime(f).utc.to_i
    end.max

    return current < expected
  end

  def self.current_bundle_timestamp(file)
    return File.read(file).to_i
  rescue StandardError
    nil
  end
end

RSpec.configure do |config|
  config.before(:each, :js) do
    AssetsTestBuild.run_assets_if_necessary
  end
end
