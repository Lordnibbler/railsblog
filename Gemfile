source 'https://rubygems.org'
ruby '2.2.0'
gem 'rails', '~> 4.2.0'

gem 'activeadmin', github: 'activeadmin' # admin UI scaffolding
gem 'client_side_validations', github: 'DavyJonesLocker/client_side_validations'
gem 'coffee-rails', '~> 4.1.0' # Use CoffeeScript for .coffee assets and views
gem 'devise', '~> 3.4.1' # authentication
gem 'friendly_id', '~> 5.1.0' # canonical URLs
gem 'high_voltage', '~> 2.2.1' # static pages
gem 'jbuilder', '~> 2.0' # Build JSON APIs with ease. @see https://github.com/rails/jbuilder
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'kaminari', '~> 0.16.2' # pagination
gem 'mail_form', '~> 1.5.0' # send email straight from a <form>
gem 'meta-tags', '~> 2.0.0' # meta tags in HTML
gem 'pg', '~> 0.18' # Use postgres as the database for Active Record
gem 'pygments.rb' # Syntax highlighting
gem 'redcarpet' # For the Markdown parsing
gem 'refills', '~> 0.1.0' # patterns and components for bourbon/neat
gem 'rouge' # syntax highlighting
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'sendgrid-ruby', '~> 0.0.3' # Sending emails
gem 'slim' # templating
gem 'turbolinks' # Turbolinks makes following links in your web application faster.
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

group :development do
  gem 'better_errors' # improved error pages
  gem 'binding_of_caller' # interact with ruby in the browser via better errors
  gem 'guard', '~> 2.11.1'
  gem 'guard-rspec', '~> 4.5'
  gem 'guard-yard', '~> 2.1.4', require: false
  gem 'guard-rubocop', '~> 1.2.0'
  gem 'quiet_assets' # shut up the asset pipeline logging
end

group :development, :test do
  gem 'awesome_print', require: 'ap' # better `p`
  gem 'brakeman', '~> 3.0.1'
  gem 'pry-byebug' # pry debugger for ruby 2.1
  gem 'rspec-rails', '~> 3.2' # rspec test suite!
  gem 'rubocop', '~> 0.28.0', require: false # keep coding styles consistent
  gem 'spring' # speed up dev env
  gem 'spring-commands-rspec' # faster rspec loading
end

group :production do
  gem 'rails_12factor'
end
