namespace :flickr do
  # usage: bx rails 'flickr:sync'
  desc 'Synchronizes Flickr photos into the database'
  task sync: :environment do |_task, _args|
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Rails.logger.info('--->  Flickr Sync: starting...')

    Rails.logger.info('--->  Flickr Sync: synchronizing photos')
    FlickrService.sync_photos
    Rails.logger.info('--->  Flickr Sync: completed synchronizing photos')
  ensure
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    Rails.logger.info("--->  Flickr Sync: finished in #{elapsed.round(2)}s")
  end
end
