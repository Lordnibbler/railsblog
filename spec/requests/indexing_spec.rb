require 'rails_helper'

RSpec.describe 'Search indexing URLs', type: :request do
  def canonical
    Nokogiri::HTML(response.body).at_css('link[rel="canonical"]')['href']
  end

  it 'redirects www paths and preserves their query strings' do
    host! 'www.benradler.com'
    get '/blog?page=3'
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to('https://benradler.com/blog?page=3')
  end

  it 'redirects the www homepage' do
    host! 'www.benradler.com'
    get '/'
    expect(response).to redirect_to('https://benradler.com/')
  end

  it 'removes legacy and tracking parameters from the homepage canonical' do
    get '/?p=141&page=4&utm_source=test'
    expect(canonical).to eq('https://benradler.com/')
  end

  it 'preserves distinct blog pagination in the canonical' do
    get '/blog?page=3&utm_source=test'
    expect(canonical).to eq('https://benradler.com/blog?page=3')
  end

  it 'uses the dated permalink for short blog URLs' do
    post = create(:post)
    get "/blog/#{post.slug}"
    expect(canonical).to eq("https://benradler.com/blog/#{post.created_at.strftime('%Y/%m/%d')}/#{post.slug}")
  end

  it 'consolidates both contact URLs' do
    get '/contact-me'
    expect(canonical).to eq('https://benradler.com/pages/contact-me')
  end

  it 'preserves the gallery seed in pagination but omits it from the canonical' do
    seed = '252435744364975031376081631016339898845'
    allow(FlickrService).to receive(:get_photos).with(page: 2, seed: seed).and_return([])
    allow(FlickrPhoto).to receive(:count).and_return(60)
    get '/photography', params: { page: 2, seed: seed }
    expect(response).to have_http_status(:ok)
    expect(canonical).to eq('https://benradler.com/photography?page=2')
    next_link = Nokogiri::HTML(response.body).at_css('a.pagination-next')['href']
    expect(Rack::Utils.parse_query(URI.parse(next_link).query)).to eq('page' => '3', 'seed' => seed)
  end

  it 'generates a new shuffle seed on each fresh gallery visit' do
    allow(Random).to receive(:new_seed).and_return(123, 456)
    allow(FlickrService).to receive(:get_photos).and_return([])
    2.times { get '/photography' }
    expect(FlickrService).to have_received(:get_photos).with(page: 1, seed: 123)
    expect(FlickrService).to have_received(:get_photos).with(page: 1, seed: 456)
    expect(canonical).to eq('https://benradler.com/photography')
  end

  it 'redirects the broken gist URL to its original source' do
    get '/Lordnibbler/11002759'
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to('https://gist.github.com/Lordnibbler/11002759')
  end
end
