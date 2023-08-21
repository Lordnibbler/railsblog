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
      expect(photo[:photo_thumbnail]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_thumbnail][:width]).to be(100)
      expect(photo[:photo_thumbnail][:height]).to be(67)
      expect(photo[:photo_small]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_small][:width]).to be(400)
      expect(photo[:photo_small][:height]).to be(267)
      expect(photo[:photo_medium]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_medium][:width]).to be(800)
      expect(photo[:photo_medium][:height]).to be(533)
      expect(photo[:photo_large]).to include(url: a_string_matching('https://live.staticflickr.com/'))
      expect(photo[:photo_large][:width]).to be(1600)
      expect(photo[:photo_large][:height]).to be(1067)
      expect(photo).to include(:created_at)
      expect(photo).to include(url: a_string_matching('https://www.flickr.com'))
      expect(photo).to include(:description)
      expect(photo).to include(:title)
    end

    it 'uses the cache to fetch' do
      expect(Rails.cache).to receive(:fetch).with(
        'flickr_photos/33668819@N03_20_1',
        expires_in: 3.days,
      )

      get_photos
    end

    it 'returns nil instead of repeating the last page', :vcr do
      expect(described_class.get_photos(page: 8)).to be_nil
    end
  end

  describe 'warm_cache_shuffled' do
    it 'fetches photos and caches them in a shuffled order' do
      allow(described_class).to receive(:get_photos)
      allow(described_class).to receive(:generate_page_cache_key).and_return('flickr_photos/user_10_1')

      described_class.warm_cache_shuffled(pages: 10)

      expect(described_class).to have_received(:get_photos).exactly(10).times
      expect(described_class).to have_received(:generate_page_cache_key).exactly(10).times
    end
  end

  describe 'total_pages' do
    it 'returns the total number of pages on users photostream', :vcr do
      total_pages = described_class.send(:total_pages)

      expect(total_pages).to eq(6)
    end
  end
end
