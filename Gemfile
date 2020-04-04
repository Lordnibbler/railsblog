source 'https://rubygems.org'
ruby '2.6.5'
gem 'rails', '5.2.4.2'

gem 'activeadmin' # admin UI scaffolding
gem 'bower-rails', '~> 0.11.0'
gem 'client_side_validations'
gem 'coffee-rails'
gem 'devise', '>= 4.4.0' # authentication for activeadmin
gem 'fog' # upload to cloud services like AWS
gem 'friendly_id' # canonical URLs
gem 'health_check' # health check endpoint for NewRelic
gem 'high_voltage' # static pages
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari' # pagination
gem 'mail_form' # send email straight from a <form> (contact page)
gem 'meta-tags' # meta tags in HTML layouts
gem 'newrelic_rpm'
gem 'pg'
gem 'pygments.rb' # Syntax highlighting in markdown
gem 'redcarpet' # For the Markdown parsing
gem 'regexp_parser', '>= 0.5.0' # force version for ruby 2.6.5+
gem 'rouge' # syntax highlighting
gem 'sass-rails'
gem 'sendgrid-ruby' # Sending emails
gem 'sitemap_generator'
gem 'slim'
gem 'turbolinks'
gem 'uglifier'

group :development do
  gem 'better_errors' # improved error pages
  gem 'binding_of_caller' # interact with ruby in the browser via better errors
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-yard', require: false
  gem 'pry-rails'
  # gem 'quiet_assets' # shut up the asset pipeline logging
  gem 'refills'
end

group :development, :test do
  gem 'awesome_print', require: 'ap' # better `p`
  gem 'brakeman'
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
  gem 'poltergeist' # phantomjs driver for capybara
  gem 'rails-controller-testing'
end

group :production do
  gem 'puma'
  gem 'rails_12factor'
end
