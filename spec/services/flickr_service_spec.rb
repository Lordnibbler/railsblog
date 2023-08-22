require 'rails_helper'

describe FlickrService do
  describe '.get_photos_from_flickr' do
    subject(:get_photos_from_flickr) { described_class.get_photos_from_flickr }

    let(:photo) { get_photos_from_flickr.first }

    it 'fetches photos from Flickr API', :vcr do
      expect(get_photos_from_flickr).to be_an Array
      expect(get_photos_from_flickr.count).to eq 20

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

    it 'returns nil instead of repeating the last page', :vcr do
      expect(described_class.get_photos_from_flickr(page: 8)).to be_nil
    end
  end

  describe 'get_photos_from_cache' do
    it 'uses the cache to fetch' do
      expect(Rails.cache).to receive(:fetch).with(
        'flickr_photos/33668819@N03_20_1',
        expires_in: 3.days,
      )

      described_class.get_photos_from_cache
    end
  end

  describe 'warm_cache_shuffled' do
    let(:photo) do
      {
        source: 'flickr',
        key: '49822917268',
        photo_thumbnail: { url: 'https://live.staticflickr.com/65535/49822917268_4d2cfb20ef_t.jpg', width: 67, height: 100 },
        photo_small: { url: 'https://live.staticflickr.com/65535/49822917268_4d2cfb20ef_w.jpg', width: 267, height: 400 },
        photo_medium: { url: 'https://live.staticflickr.com/65535/49822917268_4d2cfb20ef_c.jpg', width: 533, height: 800 },
        photo_large: { url: 'https://live.staticflickr.com/65535/49822917268_35e4540d60_h.jpg', width: 1067, height: 1600 },
        created_at: '1587941279',
        url: 'https://www.flickr.com/photos/33668819@N03/49822917268',
        description: 'Ming\'s Tasty Restaurant',
        title: 'A7306968',
      }
    end
    let(:photo_2) do
      {
        source: 'flickr',
        key: '49822922428',
        photo_thumbnail: { url: 'https://live.staticflickr.com/65535/49822922428_2944fd0b3f_t.jpg', width: 67, height: 100 },
        photo_small: { url: 'https://live.staticflickr.com/65535/49822922428_2944fd0b3f_w.jpg', width: 267, height: 400 },
        photo_medium: { url: 'https://live.staticflickr.com/65535/49822922428_2944fd0b3f_c.jpg', width: 533, height: 800 },
        photo_large: { url: 'https://live.staticflickr.com/65535/49822922428_7177310e57_h.jpg', width: 1067, height: 1600 },
        created_at: '1587941271',
        url: 'https://www.flickr.com/photos/33668819@N03/49822922428',
        description: 'Sí pero perro',
        title: 'A7302394',
      }
    end

    it 'fetches photos and caches them in a shuffled order' do
      photo_array = Array.new(20, photo)
      allow(described_class).to receive(:get_photos_from_flickr).and_return(photo_array)
      allow(described_class).to receive(:generate_photo_cache_key).and_return('flickr_photo/49822917268')
      allow(described_class).to receive(:generate_page_cache_key).and_return(
        'flickr_photos/user_10_1',
        'flickr_photos/user_10_2',
        'flickr_photos/user_10_3',
        'flickr_photos/user_10_4',
        'flickr_photos/user_10_5',
        'flickr_photos/user_10_6',
        'flickr_photos/user_10_7',
        'flickr_photos/user_10_8',
        'flickr_photos/user_10_9',
        'flickr_photos/user_10_10',
      )
      allow(Rails.cache).to receive(:write)

      described_class.warm_cache_shuffled(pages: 10)

      # fetch 10 pages of photos
      expect(described_class).to have_received(:get_photos_from_flickr).exactly(10).times

      # cache 10 pages * 20 photos per page + 1 log message
      expect(described_class).to have_received(:generate_photo_cache_key).exactly(201).times

      # cache 10 pages worth of photos
      expect(described_class).to have_received(:generate_page_cache_key).exactly(10).times

      # 20 photos * 10 pages = 200
      # 10 pages individual keys = 10
      # total = 210
      expect(Rails.cache).to have_received(:write).exactly(210).times

      # 20 photos * 10 pages = 200
      expect(Rails.cache).to have_received(:write).with('flickr_photo/49822917268', photo, expires_in: 3.days).exactly(200).times

      # 10 pages (10 batches) to be served by API
      expect(Rails.cache).to have_received(:write).with('flickr_photos/user_10_1', photo_array, expires_in: 3.days)
    end
  end

  describe 'total_pages' do
    it 'returns the total number of pages on users photostream', :vcr do
      total_pages = described_class.send(:total_pages)

      expect(total_pages).to eq(6)
    end
  end
end
