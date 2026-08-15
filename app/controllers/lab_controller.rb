# Renders interactive creative-engineering experiments.
class LabController < ApplicationController
  def index
    body_class 'lab-template'
    @photos = FlickrPhoto.order(:display_position).limit(30).map(&:as_stream_item)
    @site_status = measured_site_status
  end

  private

  def measured_site_status
    database_ms = 0.0
    thread = Thread.current
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*arguments|
      event = ActiveSupport::Notifications::Event.new(*arguments)
      database_ms += event.duration if Thread.current == thread && !%w[SCHEMA CACHE].include?(event.payload[:name])
    end
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    site_status.tap do |status|
      status[:timing] = {
        snapshot_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round(1),
        database_ms: database_ms.round(1),
      }
    end
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  def site_status
    spec_files = Rails.root.glob('spec/**/*_spec.rb')
    {
      runtime: { rails: Rails.version, ruby: RUBY_VERSION, environment: Rails.env },
      release: {
        version: ENV['HEROKU_RELEASE_VERSION'] || 'local',
        revision: (ENV['HEROKU_SLUG_COMMIT'] || ENV['SOURCE_VERSION'] || 'development').first(8),
        created_at: ENV['HEROKU_RELEASE_CREATED_AT'],
      },
      flickr: { photos: FlickrPhoto.count, last_sync: FlickrPhoto.maximum(:updated_at)&.iso8601 },
      tests: {
        files: spec_files.count,
        examples: spec_files.sum { |path| path.read.scan(/^\s*it\s+['"]/).count },
        ci: Rails.root.join('.circleci/config.yml').exist? ? 'CircleCI' : 'Not configured',
      },
      delivery: {
        assets: URI.parse(ENV.fetch('ASSET_HOST', 'https://CloudFront')).host || 'CloudFront',
        storage: Rails.application.config.active_storage.service.to_s,
        edge: 'Cloudflare → CloudFront',
        cache_control: '1 year / immutable assets',
      },
      assets: asset_inventory,
      integrations: {
        new_relic: ENV['NEW_RELIC_USER_API_KEY'].present? && ENV['NEW_RELIC_ACCOUNT_ID'].present?,
        circleci_insights: ENV['CIRCLECI_TOKEN'].present?,
      },
    }
  rescue URI::InvalidURIError
    {}
  end

  def asset_inventory
    files = Rails.root.glob('app/assets/builds/*').select(&:file?)
    {
      files: files.count,
      bytes: files.sum(&:size),
      javascript_bytes: files.select { |path| path.extname == '.js' }.sum(&:size),
      stylesheet_bytes: files.select { |path| %w[.css .sass .scss].include?(path.extname) }.sum(&:size),
    }
  end
end
