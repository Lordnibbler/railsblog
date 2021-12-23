source 'https://rubygems.org'
ruby '3.0.3'
gem 'rails', '~> 6.1'

gem 'activeadmin' # admin UI scaffolding
gem 'bcrypt', git: 'https://github.com/bcrypt-ruby/bcrypt-ruby' # NOTE: temporary lock for big sur/m1
gem 'client_side_validations' # validate forms in views before submitting to server
gem 'devise', '>= 4.4.0' # authentication for activeadmin
gem 'flickraw' # interact with flickr's API
gem 'fog-aws' # upload to AWS; used for sitemap s3 upload
gem 'friendly_id' # canonical URLs
gem 'health_check' # health check endpoint for NewRelic
gem 'high_voltage' # static pages
gem 'humanize' # convert 10 -> "ten"
gem 'jbuilder' # .builder templating
gem 'kaminari' # pagination
gem 'mail_form' # send email straight from a <form> (contact page)
gem 'meta-tags' # meta tags in HTML layouts
gem 'newrelic_rpm'
gem 'pg', git: 'https://github.com/ged/ruby-pg' # NOTE: temporary lock for big sur/m1 # ye olde database
gem 'pygments.rb' # Syntax highlighting in markdown
gem 'redcarpet', git: 'https://github.com/vmg/redcarpet' # NOTE: temporary lock for big sur/m1 # Markdown parsing
gem 'redis'
gem 'regexp_parser'
gem 'rouge' # syntax highlighting
gem 'sendgrid-ruby' # Sending emails
gem 'sitemap_generator' # generate sitemaps for submitting to search engines
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
  gem 'byebug', git: 'https://github.com/deivid-rodriguez/byebug' # NOTE: temporary lock for big sur/m1
  gem 'dotenv-rails'
  gem 'pry-byebug' # pry debugger for ruby 2.1
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring' # speed up dev env
  gem 'spring-commands-rspec' # faster rspec loading
end

group :test do
  gem 'capybara'
  gem 'launchy' # capybara save_and_open_page automatic launching
  gem 'rails-controller-testing'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end

group :production do
  gem 'puma'
end
