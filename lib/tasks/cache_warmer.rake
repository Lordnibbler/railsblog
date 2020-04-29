namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr[7]'
  desc "Warms cache for flickr API"
  task :flickr, [:num_pages] => :environment do |_task, args|
    puts "warming cache"
    Rails.cache.clear
    num_pages = args[:num_pages].to_i
    FlickrService.warm_cache_shuffled(pages: num_pages)
    puts "completed warming cache"
  end
end


