require 'features_helper'

describe 'static pages' do
  it 'renders /pages/contact-me' do
    visit page_path('contact-me')

    expect(page).to have_content('Have Any Questions?')
    expect(page).to have_css('form#new_contact_form')
    expect(page).to have_css('.page-surface')
    expect(page).to have_css('.contact-input', count: 3)
    expect(page).to have_css('.contact-details.glass-panel')
    expect(page).to have_css('.contact-detail-label', count: 3)
  end

  it 'renders /pages/squarecrusher/privacy-policy' do
    visit page_path('squarecrusher/privacy-policy')

    expect(page).to have_content('Privacy Policy')
    expect(page).to have_content('SquareCrusher!')
    expect(page).to have_css('.content-glass-panel.glass-panel')
    expect(page).to have_css('.glass-footer')
  end
end
