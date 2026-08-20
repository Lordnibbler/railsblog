# Renders interactive creative-engineering experiments.
class LabController < ApplicationController
  def index
    body_class 'lab'
    @photos = FlickrPhoto.order(Arel.sql('RANDOM()')).limit(30).map do |photo|
      photo.as_stream_item.merge(
        flickr_id: photo.flickr_id,
        composition_analysis: photo.composition_analyzed? ? photo.composition_analysis : nil,
      )
    end
    @site_status = measured_site_status
  end

  private

  def measured_site_status
    database_ms = 0.0
    thread = Thread.current
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*arguments|
      event = ActiveSupport::Notifications::Event.new(*arguments)
      database_ms += event.duration if Thread.current == thread && %w[SCHEMA CACHE].exclude?(event.payload[:name])
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
    {
      runtime: runtime_status,
      release: release_status,
      flickr: flickr_status,
      tests: test_status,
      delivery: delivery_status,
      assets: asset_inventory,
      integrations: integration_status,
    }
  rescue URI::InvalidURIError
    {}
  end

  def runtime_status
    { rails: Rails.version, ruby: RUBY_VERSION, environment: Rails.env }
  end

  def release_status
    revision = ENV['HEROKU_SLUG_COMMIT'] || ENV['SOURCE_VERSION'] || 'development'
    {
      version: ENV['HEROKU_RELEASE_VERSION'] || 'local',
      revision: revision.first(8),
      created_at: ENV.fetch('HEROKU_RELEASE_CREATED_AT', nil),
    }
  end

  def flickr_status
    photos = flickr_photos_snapshot
    total = photos.count

    {
      photos: total,
      last_sync: photos.filter_map(&:updated_at).max&.iso8601,
      metadata_bytes: photos.sum { |photo| photo.photo_data.to_json.bytesize },
      current_analysis: current_analysis_count(photos),
      analysis_errors: photos.count { |photo| photo.composition_analysis_error.present? },
      complete_renditions: complete_rendition_count(photos),
      page_size: FlickrService::GET_PHOTOS_DEFAULT_OPTIONS.fetch(:per_page),
      delivery_host: flickr_delivery_host(photos),
    }
  end

  def flickr_photos_snapshot
    FlickrPhoto.select(
      :photo_data, :composition_analysis_version, :composition_analysis_error,
      :composition_analyzed_at, :updated_at,
    ).to_a
  end

  def current_analysis_count(photos)
    photos.count { |photo| photo.composition_analysis_version == CompositionAnalysisService::VERSION }
  end

  def complete_rendition_count(photos)
    sizes = %w[photo_thumbnail photo_small photo_medium photo_large]
    photos.count { |photo| sizes.all? { |size| photo.photo_data.dig(size, 'url').present? } }
  end

  def flickr_delivery_host(photos)
    url = photos.filter_map { |photo| photo.photo_data.dig('photo_large', 'url') }.first
    URI.parse(url.to_s).host || 'Flickr static CDN'
  rescue URI::InvalidURIError
    'Flickr static CDN'
  end

  def test_status
    spec_files = Rails.root.glob('spec/**/*_spec.rb')
    {
      files: spec_files.count,
      examples: spec_files.sum { |path| path.read.scan(/^\s*it\s+['"]/).count },
      ci: Rails.root.join('.circleci/config.yml').exist? ? 'CircleCI' : 'Not configured',
    }
  end

  def delivery_status
    {
      assets: URI.parse(ENV.fetch('ASSET_HOST', 'https://CloudFront')).host || 'CloudFront',
      storage: Rails.application.config.active_storage.service.to_s,
      edge: 'Cloudflare → CloudFront',
      cache_control: '1 year / immutable assets',
    }
  end

  def integration_status
    {
      new_relic: ENV['NEW_RELIC_USER_API_KEY'].present? && ENV['NEW_RELIC_ACCOUNT_ID'].present?,
      circleci_insights: ENV['CIRCLECI_TOKEN'].present?,
    }
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
