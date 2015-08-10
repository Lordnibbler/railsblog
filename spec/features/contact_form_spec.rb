require 'features_helper'

describe '/contact-me', js: true do
  before { visit '/contact-me' }

  context 'with invalid data' do
    it 'shows inline validations' do
      within '#new_contact_form' do
        fill_in 'contact_form_email', with: 'not an email'
      end
      click_on 'Send'

      expect(page).to have_selector('label[for=contact_form_name]', text: 'can\'t be blank')
      expect(page).to have_selector('label[for=contact_form_email]', text: 'is invalid')
      expect(page).to have_selector('label[for=contact_form_name]', text: 'can\'t be blank')
    end
  end

  context 'with valid data' do
    it 'submits' do
      within '#new_contact_form' do
        fill_in 'contact_form_name', with: 'Ben Radler'
        fill_in 'contact_form_email', with: 'test@example.com'
        fill_in 'contact_form_message', with: 'Test message'
      end
      click_on 'Send'

      within '.flash-success' do
        expect(page).to have_content 'Email sent successfully'
      end
    end
  end
end
