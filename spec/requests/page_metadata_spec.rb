require 'rails_helper'

RSpec.describe 'Page metadata and markup', type: :request do
  describe 'GET /' do
    it 'uses the current page URL for canonical and social metadata' do
      get root_path

      document = Nokogiri::HTML(response.body)

      expect(document.at_css('link[rel="canonical"]')['href']).to eq('http://www.example.com/')
      expect(document.at_css('meta[property="og:url"]')['content']).to eq('http://www.example.com/')
      expect(document.at_css('meta[name="twitter:url"]')['content']).to eq('http://www.example.com/')
      expect(document.at_css('meta[itemprop="url"]')['content']).to eq('http://www.example.com/')
    end
  end

  describe 'GET /blog/:year/:month/:day/:id' do
    let!(:post) { create(:post) }
    let(:post_path) { "/blog/#{post.created_at.strftime('%Y/%m/%d')}/#{post.slug}" }

    it 'uses the current blog post URL for canonical and social metadata' do
      get post_path

      document = Nokogiri::HTML(response.body)
      expected_url = "http://www.example.com#{post_path}"

      expect(document.at_css('link[rel="canonical"]')['href']).to eq(expected_url)
      expect(document.at_css('meta[property="og:url"]')['content']).to eq(expected_url)
      expect(document.at_css('meta[name="twitter:url"]')['content']).to eq(expected_url)
      expect(document.at_css('meta[itemprop="url"]')['content']).to eq(expected_url)
    end

    it 'renders the published date inside the time element' do
      get post_path

      document = Nokogiri::HTML(response.body)
      time_element = document.at_css('time[itemprop="datePublished"]')

      expect(time_element).to be_present
      expect(time_element.text.strip).to eq(post.created_at.strftime('%B %-d, %Y %l:%M%P'))
      expect(time_element['datetime']).to eq(post.created_at.to_fs(:iso8601))
    end
  end

  describe 'GET /contact-me' do
    it 'renders a valid submit button for the contact form' do
      get '/contact-me'

      document = Nokogiri::HTML(response.body)
      submit_button = document.at_css('form#new_contact_form button[type="submit"]')

      expect(submit_button).to be_present
      expect(submit_button.text.squish).to include('Send')
      expect(submit_button.at_css('input, button')).to be_nil
    end
  end
end
