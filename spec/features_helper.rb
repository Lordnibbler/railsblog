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
# Capybara.default_driver = :chrome
# Capybara.javascript_driver = :chrome
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

Capybara.server = :webrick


# webpacker not automatically compiling before tests run, workaround from:
# https://github.com/rails/webpacker/issues/59#issuecomment-295273400
module WebpackTestBuild
  TS_FILE = Rails.root.join("tmp", "webpack-spec-timestamp")
  class << self
    attr_accessor :already_built
  end

  def self.run_webpack
    puts "running webpack-test"
    `RAILS_ENV=test bin/webpack`
    self.already_built = true
    File.open(TS_FILE, "w") { |f| f.write(Time.now.utc.to_i) }
  end

  def self.run_webpack_if_necessary
    return if self.already_built

    if timestamp_outdated?
      run_webpack
    end
  end

  def self.timestamp_outdated?
    return true if !File.exists?(TS_FILE)

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
    WebpackTestBuild.run_webpack_if_necessary
  end
end