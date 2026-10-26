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

  it 'redirects old seeded gallery URLs before loading photos' do
    expect(FlickrService).not_to receive(:get_photos)
    get '/photography?page=5&seed=252435744364975031376081631016339898845'
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to('/photography?page=5')
  end

  it 'renders stable gallery pagination and a page-specific canonical' do
    allow(FlickrService).to receive(:get_photos).with(page: 2, seed: 0).and_return([])
    allow(FlickrPhoto).to receive(:count).and_return(60)
    get '/photography?page=2'
    expect(response).to have_http_status(:ok)
    expect(canonical).to eq('https://benradler.com/photography?page=2')
    expect(Nokogiri::HTML(response.body).at_css('a.pagination-next')['href']).to eq('/photography?page=3')
  end

  it 'redirects the broken gist URL to its original source' do
    get '/Lordnibbler/11002759'
    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to('https://gist.github.com/Lordnibbler/11002759')
  end
end
