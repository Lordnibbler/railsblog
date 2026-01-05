require 'features_helper'

describe 'Contact Me page' do
  it 'renders the contact form page' do
    visit '/contact-me'

    expect(page).to have_content('Have Any Questions?')
    expect(page).to have_css('form#new_contact_form')
    expect(page).to have_field('contact_form_name')
    expect(page).to have_field('contact_form_email')
  end
end
