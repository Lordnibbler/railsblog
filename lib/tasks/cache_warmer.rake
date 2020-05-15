namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr[7]'
  desc 'Warms cache for flickr API'
  task :flickr => :environment do |_task, _args|
    puts 'warming cache'

    # clear out the existing Rails.cache
    Rails.cache.clear

    # warm the cache for num_pages worth of Flickr photos, saving
    # each page to a random index between 1..num_pages
    FlickrService.warm_cache_shuffled

    puts 'completed warming cache'
  end
end


