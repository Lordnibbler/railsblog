require 'rails_helper'

describe 'Contact Form' do
  it 'successfully renders the index template on GET /contact-me', type: :request do
    get '/contact-me'

    expect(response).to be_successful
    expect(response).to render_template('pages/contact-me')
  end

  it 'successfully renders the index template on GET /pages/contact-me', type: :request do
    get '/pages/contact-me'

    expect(response).to be_successful
    expect(response).to render_template('pages/contact-me')
  end
end
