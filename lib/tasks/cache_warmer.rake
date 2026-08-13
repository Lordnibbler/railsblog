namespace :cache_warmer do
  # usage: bx rails 'cache_warmer:flickr'
  desc 'Synchronizes Flickr photos into the database'
  task flickr: :environment do |_task, _args|
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Rails.logger.info('--->  Cache Warmer: starting...')

    Rails.logger.info('--->  Flickr Sync: synchronizing photos')
    FlickrService.sync_photos
    Rails.logger.info('--->  Flickr Sync: completed synchronizing photos')
  ensure
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    Rails.logger.info("--->  Cache Warmer: finished in #{elapsed.round(2)}s")
  end
end
