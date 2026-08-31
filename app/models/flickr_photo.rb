# Locally persisted metadata for a photo in the Flickr gallery.
class FlickrPhoto < ApplicationRecord
  validates :flickr_id, :display_position, presence: true
  validates :flickr_id, :display_position, uniqueness: true

  def as_stream_item
    photo_data.deep_symbolize_keys
  end

  def composition_analyzed?
    composition_analysis.present?
  end
end
