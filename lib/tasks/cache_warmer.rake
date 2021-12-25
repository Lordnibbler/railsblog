namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr'
  desc 'Warms cache for flickr API'
  task :flickr => :environment do |_task, _args|
    Rails.logger.info('--->  Cache Warmer: starting...')

    # return if cache is warm already when deploying, avoiding unnecessary calls to flickr
    if Rails.cache.fetch(FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY) == true
      Rails.logger.info('--->  Cache Warmer: Cache already warm, exiting')
    else
      # clear out the existing Rails.cache
      Rails.logger.info('--->  Cache Warmer: Clearing existing cache')
      Rails.cache.clear

      # warm the cache for num_pages worth of Flickr photos, saving
      # each page to a random index between 1..num_pages
      Rails.logger.info('--->  Cache Warmer: Warming Flickr cache')
      FlickrService.warm_cache_shuffled

      Rails.logger.info('--->  Cache Warmer: Marking cache as warmed')
      Rails.cache.write(FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY, true, expires_in: 1.day)

      Rails.logger.info('--->  Cache Warmer: completed warming cache')
    end
  end
end


