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

    it 'only loads the frontend bundle used by the homepage contact form' do
      get root_path

      document = Nokogiri::HTML(response.body)
      asset_urls = document.css('script[src], link[rel="stylesheet"]').filter_map do |element|
        element['src'] || element['href']
      end

      expect(asset_urls).to include(a_string_matching(/contact-me/))
      expect(asset_urls).not_to include(a_string_matching(/photography|blog|pygment/))
    end

    it 'describes current high-scale systems experience' do
      get root_path

      document = Nokogiri::HTML(response.body)

      expect(document.at_css('meta[name="description"]')['content']).to include('high-scale systems')
      expect(document.at_css('meta[property="og:description"]')['content']).to include('Cruise', 'Lyft')
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

    it 'only loads the blog-specific frontend assets' do
      get post_path

      document = Nokogiri::HTML(response.body)
      asset_urls = document.css('script[src], link[rel="stylesheet"]').filter_map do |element|
        element['src'] || element['href']
      end

      expect(asset_urls).to include(a_string_matching(/blog/), a_string_matching(/pygment/))
      expect(asset_urls).not_to include(a_string_matching(/photography|contact-me/))
    end
  end

  describe 'GET /contact-me' do
    it 'loads the contact form stylesheet' do
      get '/contact-me'

      document = Nokogiri::HTML(response.body)
      stylesheet_urls = document.css('link[rel="stylesheet"]').filter_map { |element| element['href'] }

      expect(stylesheet_urls).to include(a_string_matching(/contact-me/))
    end

    it 'renders a valid submit button for the contact form' do
      get '/contact-me'

      document = Nokogiri::HTML(response.body)
      submit_button = document.at_css('form#new_contact_form button[type="submit"]')

      expect(submit_button).to be_present
      expect(submit_button.text.squish).to include('Send')
      expect(submit_button.at_css('input, button')).to be_nil
    end

    it 'associates labels with required contact fields' do
      get '/contact-me'

      document = Nokogiri::HTML(response.body)

      %w[name email message].each do |field|
        input = document.at_css("#contact_form_#{field}")
        label = document.at_css("label[for='contact_form_#{field}']")

        expect(input['required']).to be_present
        expect(label).to be_present
      end
    end
  end
end
