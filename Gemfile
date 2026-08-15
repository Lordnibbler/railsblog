source 'https://rubygems.org'
ruby '4.0.6'
gem 'rails', '~> 8'

gem 'activeadmin', '~> 3' # admin UI scaffolding
gem 'client_side_validations' # validate forms in views before submitting to server
gem 'concurrent-ruby' # concurrency, used in FlickrService
gem 'connection_pool', '< 3' # Rails 8.1 calls ConnectionPool with positional args
gem 'devise', '>= 4.4.0' # authentication for activeadmin
gem 'flickr' # interact with flickr's API
gem 'friendly_id' # canonical URLs
gem 'high_voltage' # static pages
gem 'humanize' # convert 10 -> "ten"
gem 'image_processing' # process representations of ActiveSupport images
gem 'jsbundling-rails'
gem 'kaminari' # pagination
gem 'mail_form' # send email straight from a <form> (contact page)
gem 'meta-tags' # meta tags in HTML layouts
gem 'pg' # ye olde database
gem 'propshaft'
gem 'redcarpet' # Markdown parsing
gem 'rouge' # syntax highlighting
gem 'slim' # view templating

group :development, :production do
  gem 'puma'
end

group :development do
  gem 'better_errors' # improved error pages
  gem 'binding_of_caller' # interact with ruby in the browser via better errors
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard'
  gem 'pry-rails'
  gem 'pry-byebug', require: false # byebug requires readline; only load it when debugging explicitly
end

group :development, :test do
  gem 'awesome_print', require: 'ap' # better `p`
  gem 'brakeman'
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop', require: false
  gem 'spring' # speed up dev env
end

group :test do
  gem 'capybara' # frontend testing framework
  gem 'factory_bot_rails' # factories
  gem 'launchy' # capybara save_and_open_page automatic launching
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter' # formatting for circleci
  gem 'vcr' # record http requests and play them back in tests
  gem 'webrick' # Capybara test server
  gem 'webdrivers'
  gem 'webmock'
end

group :production do
  gem 'aws-sdk-s3', require: false # AWS uploads for Active Storage and sitemaps
  gem 'health_check' # health check endpoint for New Relic
  gem 'newrelic_rpm'
  gem 'sitemap_generator' # generate sitemaps for submitting to search engines
end
