source 'https://rubygems.org'
ruby '2.3.1'
gem 'rails', '5.0.0.1'

gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin.git' # admin UI scaffolding
gem 'inherited_resources', git: 'https://github.com/activeadmin/inherited_resources.git'
gem 'client_side_validations', git: 'https://github.com/DavyJonesLocker/client_side_validations.git', branch: 'rails5'
gem 'coffee-rails'
gem 'devise' # authentication for activeadmin
gem 'flickraw' # interact with flickr's API
gem 'fog' # upload to cloud services like AWS
gem 'friendly_id' # canonical URLs
gem 'health_check' # health check endpoint for NewRelic
gem 'high_voltage' # static pages
gem 'instagram', '~> 1.1.5' # interact with instagram's API
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari' # pagination
gem 'mail_form', git: 'https://github.com/plataformatec/mail_form.git' # send email straight from a <form> (contact page)
gem 'meta-tags' # meta tags in HTML layouts
gem 'newrelic_rpm'
gem 'pg'
gem 'pygments.rb' # Syntax highlighting in markdown
gem 'redcarpet' # For the Markdown parsing
gem 'redis-rails'
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
  gem 'guard-yard', require: false
  gem 'guard-rubocop'
  gem 'pry-rails'
  # gem 'quiet_assets' # shut up the asset pipeline logging
  gem 'refills'
end

group :development, :test do
  gem 'awesome_print', require: 'ap' # better `p`
  gem 'brakeman'
  gem 'dotenv-rails'
  gem 'foreman' # Manage application processes
  gem 'pry-byebug' # pry debugger for ruby 2.2+
  gem 'rspec-rails'
  gem 'rubocop', require: false
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
