require 'features_helper'

describe 'static pages' do
  it 'renders /pages/contact-me' do
    visit page_path('contact-me')

    expect(page).to have_content('Have Any Questions?')
    expect(page).to have_css('form#new_contact_form')
  end

  it 'renders /pages/squarecrusher/privacy-policy' do
    visit page_path('squarecrusher/privacy-policy')

    expect(page).to have_content('Privacy Policy')
    expect(page).to have_content('SquareCrusher!')
  end
end
