require 'features_helper'

describe 'API stream endpoints' do
  it 'returns JSON from /api/v1/stream' do
    photos = [{ 'id' => '1' }, { 'id' => '2' }]
    allow(FlickrService).to receive(:get_photos).and_return(photos)

    visit '/api/v1/stream'

    expect(page.status_code).to eq(200)
    expect(page.response_headers['Content-Type']).to include('application/json')
    expect(JSON.parse(page.body)).to eq(photos)
  end

  it 'returns JSON from /api/v1/stream/flickr with paging' do
    photos = [{ 'id' => '9' }]
    allow(FlickrService).to receive(:get_photos).and_return(photos)

    visit '/api/v1/stream/flickr?page=1'

    expect(page.status_code).to eq(200)
    body = JSON.parse(page.body)
    expect(body['source']).to eq('flickr')
    expect(body['page']).to eq(2)
    expect(body['posts']).to eq(photos)
  end
end
