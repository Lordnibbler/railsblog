require 'rails_helper'
require 'rake'
require 'sitemap_generator'

RSpec.describe 'Sitemap refresh task' do
  it 'generates the sitemap without invoking the obsolete ping action' do
    original_application = Rake.application
    Rake.application = Rake::Application.new
    load Gem::Specification.find_by_name('sitemap_generator').full_gem_path + '/lib/sitemap_generator/tasks.rb'
    allow(Rails.application).to receive(:load_tasks)
    load File.expand_path('../../Rakefile', __dir__)

    create_task = Rake::Task['sitemap:create']
    create_task.clear
    generated = false
    create_task.enhance { generated = true }
    expect(SitemapGenerator::Sitemap).not_to receive(:ping_search_engines)

    Rake::Task['sitemap:refresh'].invoke

    expect(generated).to be(true)
  ensure
    Rake.application = original_application
  end
end
