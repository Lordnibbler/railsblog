require 'rails_helper'

describe InstagramService do
  describe '.user_recent_media' do
    before do
      Rails.cache.clear
    end

    subject(:user_recent_media) { described_class.user_recent_media }
    let(:media) { user_recent_media.first }

    it 'fetches media for the user from Instagram API', :vcr do
      expect(user_recent_media).to be_an(Array)
      expect(user_recent_media.count).to eq(20)

      expect(media).to include(source: a_string_matching('instagram'))
      expect(media).to include(:key)
      expect(media).to include(url_thumbnail: a_string_matching('https://scontent.cdninstagram.com'))
      expect(media).to include(url_original: a_string_matching('https://scontent.cdninstagram.com'))
      expect(media).to include(:created_at)
      expect(media).to include(description: a_string_matching('#sanfrancisco'))
      expect(media).to include(:title)
    end

    it 'uses the cache to fetch' do
      expect(Rails.cache).to receive(:fetch).with(
        'instagram_photos_newest',
        expires_in: 12.hours
      )

      user_recent_media
    end

    context 'given bad access token' do
      it 'returns an error'
    end
  end
end
