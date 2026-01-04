require 'features_helper'

describe '/contact-me' do
  context 'with invalid data', :js do
    before { visit '/contact-me' }

    it 'shows inline validations' do
      click_on 'Send'
      expect(page).to have_css('label[for=contact_form_name]', text: 'can\'t be blank')

      within '#new_contact_form' do
        fill_in 'contact_form_email', with: 'not an email'
      end
      click_on 'Send'
      expect(page).to have_css('label[for=contact_form_email]', text: 'is invalid')
    end
  end

  context 'with valid data' do
    before { visit '/contact-me' }

    it 'submits' do
      within '#new_contact_form' do
        fill_in 'contact_form_name', with: 'Ben Radler'
        fill_in 'contact_form_email', with: 'test@example.com'
        fill_in 'contact_form_message', with: 'Test message'
      end
      click_on 'Send'

      within '.flash-success' do
        expect(page).to have_content 'Contact form successfully sent. I will reach back out as soon as I can!'
      end
    end
  end
end
