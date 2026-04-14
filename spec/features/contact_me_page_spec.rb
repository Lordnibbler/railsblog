require 'features_helper'

describe 'Contact Me page' do
  it 'renders the contact form page' do
    visit '/contact-me'

    expect(page).to have_content('Have Any Questions?')
    expect(page).to have_css('form#new_contact_form')
    expect(page).to have_field('contact_form_name')
    expect(page).to have_field('contact_form_email')
  end

  it 'renders the success flash inside the page content after submit' do
    visit '/contact-me'

    within '#new_contact_form' do
      fill_in 'contact_form_name', with: 'Ben Radler'
      fill_in 'contact_form_email', with: 'test@example.com'
      fill_in 'contact_form_message', with: 'Test message'
      click_on 'Send'
    end

    within '#pages-show' do
      expect(page).to have_css('.flash-success')
      expect(page).to have_content('Have Any Questions?')
    end
  end
end
