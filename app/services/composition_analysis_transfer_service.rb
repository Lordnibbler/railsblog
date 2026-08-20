require 'digest'

# Exports and imports paid composition readings without invoking the vision API.
class CompositionAnalysisTransferService
  FORMAT_VERSION = 1

  class << self
    def export
      records = FlickrPhoto.where.not(composition_analysis: {}).order(:flickr_id).map do |photo|
        {
          flickr_id: photo.flickr_id,
          composition_analysis: photo.composition_analysis,
          composition_analysis_version: photo.composition_analysis_version,
          composition_analyzed_at: photo.composition_analyzed_at&.iso8601(6),
        }
      end
      JSON.pretty_generate(
        format_version: FORMAT_VERSION,
        record_count: records.length,
        checksum: checksum(records),
        records:,
      )
    end

    def import(json)
      payload = JSON.parse(json)
      records = payload.fetch('records')
      validate!(payload, records)
      photos = FlickrPhoto.where(flickr_id: records.pluck('flickr_id')).index_by(&:flickr_id)
      missing = records.pluck('flickr_id') - photos.keys
      raise "Missing Flickr photos: #{missing.join(', ')}" if missing.any?

      FlickrPhoto.transaction do
        records.each do |record|
          photos.fetch(record.fetch('flickr_id')).update!(
            composition_analysis: record.fetch('composition_analysis'),
            composition_analysis_version: record['composition_analysis_version'],
            composition_analyzed_at: record['composition_analyzed_at'],
            composition_analysis_error: nil,
          )
        end
      end
      records.length
    end

    private

    def validate!(payload, records)
      raise "Unsupported format version #{payload['format_version']}" unless payload['format_version'] == FORMAT_VERSION
      raise 'Record count does not match payload' unless payload['record_count'] == records.length
      raise 'Duplicate Flickr IDs in payload' unless records.pluck('flickr_id').uniq.length == records.length
      raise 'Composition analysis checksum mismatch' unless ActiveSupport::SecurityUtils.secure_compare(
        payload.fetch('checksum'), checksum(records),
      )
    end

    def checksum(records)
      Digest::SHA256.hexdigest(JSON.generate(records))
    end
  end
end
