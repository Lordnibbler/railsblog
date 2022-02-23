require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Brog
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.eager_load_paths << Rails.root.join("extras")

    # configure autoload paths
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # custom error pages defined by errors_controller.rb
    config.exceptions_app = self.routes

    # Change the variant processor for Active Storage.
    config.active_storage.variant_processor = :mini_magick

    config.assets.paths << Rails.root.join('app', 'assets', 'builds')
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  end
end
