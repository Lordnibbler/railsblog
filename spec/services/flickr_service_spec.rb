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
      expect(photo).to include(url_thumbnail: a_string_matching('https://farm9.staticflickr.com'))
      expect(photo).to include(url_original: a_string_matching('https://farm9.staticflickr.com'))
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
  end
end
