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
      expect(photo[:photo_thumbnail][:width]).to eql(100)
      expect(photo[:photo_thumbnail][:height]).to eql(67)
      expect(photo[:photo_small]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_small][:width]).to eql(400)
      expect(photo[:photo_small][:height]).to eql(267)
      expect(photo[:photo_medium]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_medium][:width]).to eql(800)
      expect(photo[:photo_medium][:height]).to eql(533)
      expect(photo[:photo_large]).to include(url: a_string_matching('https://live.staticflickr.com/'))
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
      allow(FlickrService).to receive(:get_photos)
      allow(FlickrService).to receive(:generate_cache_key).and_return('flickr_photos_user_10_1')

      FlickrService.warm_cache_shuffled(pages: 10)

      expect(FlickrService).to have_received(:get_photos).exactly(10).times
      expect(FlickrService).to have_received(:generate_cache_key).exactly(10).times
    end
  end

  describe 'total_pages' do
    it 'returns the total number of pages on users photostream' do
      response = double(FlickRaw::ResponseList, pages: 3)
      allow(FlickrService.send(:client).people).to receive(:getPhotos).and_return(response)

      total_pages = FlickrService.send(:total_pages)

      expect(total_pages).to eq(3)
    end
  end
end
