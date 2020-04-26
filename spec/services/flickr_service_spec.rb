require 'rails_helper'

describe FlickrService do
  describe '.get_photos' do
    subject(:get_photos) { described_class.get_photos }
    let(:photo) { get_photos.first }

    it 'fetches photos from Flickr API', :vcr do
      expect(get_photos).to be_an Array
      expect(get_photos.count).to eq 20

      expect(photo).to include(source: a_string_matching('flickr'))
      expect(photo).to include(:key)
      expect(photo[:photo_thumbnail]).to include(url: a_string_matching('https://farm6.staticflickr.com'))
      expect(photo[:photo_thumbnail][:width]).to eql(100)
      expect(photo[:photo_thumbnail][:height]).to eql(67)
      expect(photo[:photo_large]).to include(url: a_string_matching('https://farm6.staticflickr.com'))
      expect(photo[:photo_large][:width]).to eql(1600)
      expect(photo[:photo_large][:height]).to eql(1067)
      expect(photo).to include(:created_at)
      expect(photo).to include(url: a_string_matching('https://www.flickr.com'))
      expect(photo).to include(:description)
      expect(photo).to include(:title)
    end

    it 'uses the cache to fetch' do
      expect(Rails.cache).to receive(:fetch).with(
        'flickr_photos_33668819@N03_20_1',
        expires_in: 5.minutes
      )

      get_photos
    end

    it 'returns nil instead of repeating the last page' do
      expect(described_class.get_photos(page: 3)).to be_nil
    end
  end
end