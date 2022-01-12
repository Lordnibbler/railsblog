source 'https://rubygems.org'
ruby '3.1.0'
gem 'rails', '~> 6.1'

gem 'activeadmin' # admin UI scaffolding
gem 'aws-sdk-s3', require: false # aws uploads for ActiveStorage production
gem 'client_side_validations' # validate forms in views before submitting to server
gem 'devise', '>= 4.4.0' # authentication for activeadmin
gem 'flickraw' # interact with flickr's API
gem 'fog-aws' # upload to AWS; used for sitemap s3 upload
gem 'friendly_id' # canonical URLs
gem 'health_check' # health check endpoint for NewRelic
gem 'high_voltage' # static pages
gem 'humanize' # convert 10 -> "ten"
gem 'image_processing' # process representations of ActiveSupport images
gem 'jbuilder' # .builder templating
gem 'kaminari' # pagination
gem 'mail_form' # send email straight from a <form> (contact page)
gem 'meta-tags' # meta tags in HTML layouts
gem 'net-imap', require: false # remove once upgrading to Rails 7.0.1 or newer (https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp)
gem 'net-pop', require: false # remove once upgrading to Rails 7.0.1 or newer (https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp)
gem 'net-smtp', require: false # remove once upgrading to Rails 7.0.1 or newer (https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp)
gem 'newrelic_rpm'
gem 'pg' # ye olde database
gem 'pygments.rb' # Syntax highlighting in markdown
gem 'redcarpet' # Markdown parsing
gem 'redis'
gem 'regexp_parser'
gem 'rouge' # syntax highlighting
gem 'sendgrid-ruby' # Sending emails
gem 'sitemap_generator', github: 'kjvarga/sitemap_generator' # remove once 6.2.0 is released # generate sitemaps for submitting to search engines
gem 'slim' # view templating
gem 'uglifier'
gem 'webpacker' # webpack integration with rails
gem 'webrick' # web server for capybara and local dev

group :development do
  gem 'better_errors' # improved error pages
  gem 'binding_of_caller' # interact with ruby in the browser via better errors
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-yard', require: false
  gem 'pry-rails'
end

group :development, :test do
  gem 'awesome_print', require: 'ap' # better `p`
  gem 'brakeman'
  gem 'dotenv-rails'
  gem 'flickraw-cached' # for deterministic unit tests in random order, cache available flickr methods
  gem 'pry-byebug' # pry debugger for ruby 2.1
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring' # speed up dev env
  gem 'spring-commands-rspec' # faster rspec loading
end

group :test do
  gem 'capybara' # frontend testing framework
  gem 'factory_bot_rails' # factories
  gem 'launchy' # capybara save_and_open_page automatic launching
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter' # formatting for circleci
  gem 'vcr', github: 'vcr/vcr' # return to rubygems once newer version than 6.0.0 is released # record http requests and play them back in tests
  gem 'webdrivers'
  gem 'webmock'
end

group :production do
  gem 'puma'
end
