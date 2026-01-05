require 'rails_helper'

RSpec.describe Api::V1::StreamController do
  describe 'GET #index' do
    it 'renders photos from FlickrService' do
      photos = [{ 'id' => '1' }, { 'id' => '2' }]
      allow(FlickrService).to receive(:get_photos).and_return(photos)

      get :index

      expect(response.media_type).to eq('application/json')
      expect(response.parsed_body).to eq(photos)
    end

    it 'passes the page param through to FlickrService' do
      allow(FlickrService).to receive(:get_photos).and_return([])

      get :index, params: { page: '3' }

      expect(FlickrService).to have_received(:get_photos).with(page: '3')
    end
  end

  describe 'GET #flickr' do
    it 'returns the next page when page param is present' do
      photos = [{ 'id' => '1' }]
      allow(FlickrService).to receive(:get_photos).and_return(photos)

      get :flickr, params: { page: '4' }

      body = response.parsed_body
      expect(body['source']).to eq('flickr')
      expect(body['page']).to eq(5)
      expect(body['posts']).to eq(photos)
      expect(FlickrService).to have_received(:get_photos).with(page: '4')
    end

    it 'defaults the next page to 2 when no page param is present' do
      allow(FlickrService).to receive(:get_photos).and_return([])

      get :flickr

      body = response.parsed_body
      expect(body['page']).to eq(2)
      expect(FlickrService).to have_received(:get_photos).with(page: nil)
    end
  end
end
