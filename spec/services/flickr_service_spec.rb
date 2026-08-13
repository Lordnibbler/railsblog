require 'rails_helper'

describe FlickrService do
  describe 'logger' do
    it 'reuses the same logger instance' do
      expect(described_class.logger).to equal(described_class.logger)
    end
  end

  describe 'get_photos_from_flickr' do
    subject(:get_photos_from_flickr) { described_class.get_photos_from_flickr }

    let(:photo) { get_photos_from_flickr.first }

    it 'fetches photos from Flickr API', :vcr do
      expect(get_photos_from_flickr).to be_an Array
      expect(get_photos_from_flickr.count).to eq 20

      expect(photo).to include(source: a_string_matching('flickr'))
      expect(photo).to include(:key)
      expect(photo[:photo_thumbnail]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_thumbnail][:width]).to be(67)
      expect(photo[:photo_thumbnail][:height]).to be(100)
      expect(photo[:photo_small]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_small][:width]).to be(267)
      expect(photo[:photo_small][:height]).to be(400)
      expect(photo[:photo_medium]).to include(url: a_string_matching('https://live.staticflickr.com'))
      expect(photo[:photo_medium][:width]).to be(533)
      expect(photo[:photo_medium][:height]).to be(800)
      expect(photo[:photo_large]).to include(url: a_string_matching('https://live.staticflickr.com/'))
      expect(photo[:photo_large][:width]).to be(683)
      expect(photo[:photo_large][:height]).to be(1024)
      expect(photo).to include(:created_at)
      expect(photo).to include(url: a_string_matching('https://www.flickr.com'))
      expect(photo).to include(:description)
      expect(photo).to include(:title)
    end

    it 'returns nil instead of repeating the last page', :vcr do
      expect(described_class.get_photos_from_flickr(page: 10)).to be_nil
    end
  end

  describe 'get_photos' do
    let(:photo) do
      {
        source: 'flickr',
        key: '49822917268',
        photo_thumbnail: {
          url: 'https://live.staticflickr.com/65535/49822917268_4d2cfb20ef_t.jpg',
          width: 67,
          height: 100,
        },
        photo_small: {
          url: 'https://live.staticflickr.com/65535/49822917268_4d2cfb20ef_w.jpg',
          width: 267,
          height: 400,
        },
        photo_medium: {
          url: 'https://live.staticflickr.com/65535/49822917268_4d2cfb20ef_c.jpg',
          width: 533,
          height: 800,
        },
        photo_large: {
          url: 'https://live.staticflickr.com/65535/49822917268_35e4540d60_h.jpg',
          width: 1067,
          height: 1600,
        },
        created_at: '1587941279',
        url: 'https://www.flickr.com/photos/33668819@N03/49822917268',
        description: 'Ming\'s Tasty Restaurant',
        title: 'A7306968',
      }
    end
    let(:photo2) do
      {
        source: 'flickr',
        key: '49822922428',
        photo_thumbnail: {
          url: 'https://live.staticflickr.com/65535/49822922428_2944fd0b3f_t.jpg',
          width: 67,
          height: 100,
        },
        photo_small: {
          url: 'https://live.staticflickr.com/65535/49822922428_2944fd0b3f_w.jpg',
          width: 267,
          height: 400,
        },
        photo_medium: {
          url: 'https://live.staticflickr.com/65535/49822922428_2944fd0b3f_c.jpg',
          width: 533,
          height: 800,
        },
        photo_large: {
          url: 'https://live.staticflickr.com/65535/49822922428_7177310e57_h.jpg',
          width: 1067,
          height: 1600,
        },
        created_at: '1587941271',
        url: 'https://www.flickr.com/photos/33668819@N03/49822922428',
        description: 'Sí pero perro',
        title: 'A7302394',
      }
    end

    it 'uses a repeatable random order for a seed' do
      FlickrPhoto.create!(flickr_id: photo2[:key], photo_data: photo2, display_position: 2)
      FlickrPhoto.create!(flickr_id: photo[:key], photo_data: photo, display_position: 1)

      first_result = described_class.get_photos(seed: 123)

      expect(described_class.get_photos(seed: 123)).to eq(first_result)
      expect(first_result).to contain_exactly(photo.deep_symbolize_keys, photo2.deep_symbolize_keys)
    end
  end

  describe 'sync_photos' do
    let(:old_photo) { { source: 'flickr', key: 'old', title: 'Old' } }
    let(:new_photo) { { source: 'flickr', key: 'new', title: 'New' } }

    it 'atomically replaces stale photos with the fetched catalog' do
      FlickrPhoto.create!(flickr_id: 'old', photo_data: old_photo, display_position: 1)
      allow(described_class).to receive(:fetch_and_randomize_photos).with(1).and_return([new_photo])

      described_class.sync_photos(pages: 1)

      expect(FlickrPhoto.pluck(:flickr_id, :display_position)).to eq([['new', 1]])
      expect(described_class.get_photos(seed: 1)).to eq([new_photo])
    end

    it 'leaves existing photos intact when fetching fails' do
      FlickrPhoto.create!(flickr_id: 'old', photo_data: old_photo, display_position: 1)
      allow(described_class).to receive(:fetch_and_randomize_photos).and_raise(Net::ReadTimeout)

      expect { described_class.sync_photos(pages: 1) }.to raise_error(Net::ReadTimeout)
      expect(described_class.get_photos(seed: 1)).to eq([old_photo])
    end
  end

  describe 'total_pages' do
    it 'returns the total number of pages on users photostream', :vcr do
      total_pages = described_class.send(:total_pages)

      expect(total_pages).to eq(8)
    end
  end

  describe 'fetch_photos_with_retry' do
    let(:logger) { instance_double(Logger, info: nil, error: nil) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
    end

    it 'retries retryable Flickr fetch failures' do
      attempts = 0
      photos = [{ key: '49822917268' }]

      allow(described_class).to receive(:get_photos_from_flickr) do
        attempts += 1
        raise Net::ReadTimeout if attempts == 1

        photos
      end

      expect(described_class.send(:fetch_photos_with_retry, 1)).to eq(photos)
      expect(described_class).to have_received(:get_photos_from_flickr).with(page: 1).twice
    end

    it 'raises retryable failures after configured retries are exhausted' do
      original_retries = ENV.fetch('FLICKR_CACHE_WARMER_RETRIES', nil)
      ENV['FLICKR_CACHE_WARMER_RETRIES'] = '1'
      error = EOFError.new('connection closed')

      allow(described_class).to receive(:get_photos_from_flickr).and_raise(error)

      expect { described_class.send(:fetch_photos_with_retry, 1) }.to raise_error(error)
      expect(described_class).to have_received(:get_photos_from_flickr).with(page: 1).twice
    ensure
      ENV['FLICKR_CACHE_WARMER_RETRIES'] = original_retries
    end

    it 'does not retry non-retryable failures' do
      error = ArgumentError.new('bad page')
      allow(described_class).to receive(:get_photos_from_flickr).and_raise(error)

      expect { described_class.send(:fetch_photos_with_retry, 1) }.to raise_error(error)
      expect(described_class).to have_received(:get_photos_from_flickr).with(page: 1).once
    end
  end

  describe 'fetch_and_randomize_photos' do
    let(:logger) { instance_double(Logger, info: nil, error: nil) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
    end

    it 'uses future value bang so async failures are raised' do
      future = instance_double(Concurrent::Future)
      error = Net::ReadTimeout.new('timed out')

      allow(future).to receive(:value!).and_raise(error)
      allow(described_class).to receive(:fetch_photos_future).with(1).and_return(future)

      expect { described_class.send(:fetch_and_randomize_photos, 1) }.to raise_error(error)
    end
  end
end
