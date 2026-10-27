# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

# Keep sitemap generation/upload, but skip the gem's obsolete search-engine ping.
# That action also requires cgi/session, which is unavailable in this runtime.
Rake::Task['sitemap:refresh'].clear_actions
