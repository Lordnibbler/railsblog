require 'rails_helper'

RSpec.describe 'Redirects', type: :request do
  it 'redirects /resume to Google Docs' do
    get '/resume'

    expect(response).to have_http_status(:moved_permanently)
    expect(response.headers['Location']).to eq(
      'https://docs.google.com/document/d/1j8uZ5G3rY1xxy1xJERt3SFhwicP7zzDTdofY8hLLmM0',
    )
  end

  it 'redirects /resume-pdf to the downloads path' do
    get '/resume-pdf'

    expect(response).to have_http_status(:moved_permanently)
    expect(response.headers['Location']).to end_with('/resume/downloads/radler-resume.pdf')
  end

  it 'redirects /sitemap.xml.gz to S3' do
    get '/sitemap.xml.gz'

    expect(response).to have_http_status(:moved_permanently)
    expect(response.headers['Location']).to eq(
      'https://benradler-sitemap-production.s3.amazonaws.com/sitemaps/sitemap.xml.gz',
    )
  end
end
