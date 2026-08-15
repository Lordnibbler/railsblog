namespace :flickr do
  # usage: bx rails 'flickr:sync' or bx rails 'flickr:sync[force]'
  desc 'Synchronizes Flickr photos into the database'
  task :sync, [:composition] => :environment do |_task, args|
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Rails.logger.info('--->  Flickr Sync: starting...')

    Rails.logger.info('--->  Flickr Sync: synchronizing photos')
    FlickrService.sync_photos
    Rails.logger.info('--->  Flickr Sync: completed synchronizing photos')
    force = args[:composition] == 'force'
    analyzed = CompositionAnalysisService.analyze_pending(force:)
    Rails.logger.info("--->  Flickr Sync: analyzed #{analyzed} new photograph compositions")
  ensure
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    Rails.logger.info("--->  Flickr Sync: finished in #{elapsed.round(2)}s")
  end

  desc 'Analyzes Flickr photo composition with a vision model and stores results in PostgreSQL'
  task :analyze_compositions, [:mode] => :environment do |_task, args|
    abort('OPENAI_API_KEY is not configured') unless CompositionAnalysisService.configured?

    force = args[:mode] == 'force'
    analyzed = CompositionAnalysisService.analyze_pending(force:)
    Rails.logger.info("--->  Composition Analysis: analyzed #{analyzed} photographs")
  end

  desc 'Exports persisted composition analyses as checksummed JSON without API calls'
  task export_composition_analyses: :environment do
    $stdout.write(CompositionAnalysisTransferService.export)
  end

  desc 'Imports checksummed composition analyses from FILE or standard input without API calls'
  task import_composition_analyses: :environment do
    source = ENV['FILE'].present? ? File.read(ENV.fetch('FILE')) : $stdin.read
    imported = CompositionAnalysisTransferService.import(source)
    Rails.logger.info("Imported #{imported} composition analyses without API calls")
  end
end
