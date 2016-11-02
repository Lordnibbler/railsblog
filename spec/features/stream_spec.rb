require 'features_helper'

RSpec.shared_context 'api response' do
  let(:response) { JSON.parse(page.body).with_indifferent_access }
  let(:posts) { response[:posts] }
end

RSpec.shared_examples 'stream api schema' do |path|
  include_context 'api response'

  it 'renders the expected JSON schema', :vcr do
    visit send(path)
    expect(response).to have_key(:source)
    expect(response).to have_key(:page)
    expect(response).to have_key(:posts)

    expect(posts).to be_an Array
    expect(posts.count).to eq 20
    expect(posts.first).to include(
      :source,
      :key,
      :url_thumbnail,
      :url_original,
      :created_at,
      :url,
      :description,
      :title
    )
  end
end

describe 'api/v1' do
  describe '/instagram' do
    it_behaves_like 'stream api schema', :instagram_api_v1_stream_index_path
  end

  describe '/flickr' do
    it_behaves_like 'stream api schema', :flickr_api_v1_stream_index_path
  end
end
