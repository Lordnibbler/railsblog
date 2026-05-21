namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr'
  desc 'Warms cache for flickr API'
  task flickr: :environment do |_task, _args|
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Rails.logger.info('--->  Cache Warmer: starting...')

    Rails.logger.info('--->  Cache Warmer: Warming Flickr cache')
    FlickrService.warm_cache_shuffled

    Rails.logger.info('--->  Cache Warmer: Marking cache as warmed')
    Rails.cache.write(FlickrService::PHOTOGRAPHY_CACHE_WARMED_KEY, true, expires_in: 25.hours)

    Rails.logger.info('--->  Cache Warmer: completed warming cache')
  ensure
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    Rails.logger.info("--->  Cache Warmer: finished in #{elapsed.round(2)}s")
  end
end
