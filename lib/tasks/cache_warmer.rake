namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr[7]'
  desc 'Warms cache for flickr API'
  task :flickr, [:num_pages] => :environment do |_task, args|
    puts 'warming cache'

    # clear out the existing Rails.cache
    Rails.cache.clear

    # determine how many pages of Flickr photos (in groups of 20) we should fetch
    num_pages = args[:num_pages].to_i

    # warm the cache for num_pages worth of Flickr photos, saving
    # each page to a random index between 1..num_pages
    FlickrService.warm_cache_shuffled(pages: num_pages)

    puts 'completed warming cache'
  end
end


