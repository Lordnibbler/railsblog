require 'features_helper'

describe '/' do
  before { visit root_path }


  context 'latest blog posts' do
    fixtures :posts

    let!(:post) { posts(:short) }
    let!(:long_post) { posts(:long) }
    let!(:unpublished_post) { posts(:unpublished) }

    it 'shows all published posts' do
      within '#latest' do
        expect(page).to have_selector('a.shadow.bg-white', count: 2)
      end
    end

    context 'when clicking Continue Reading' do
      it 'shows full post' do
        within '#latest' do
           page.first(:css, 'a.shadow.bg-white').click
        end
  
        expect(page).to have_content 'Bacon ipsum dolor amet shankle beef'
        expect(page).to have_content /Next Post/i
        expect(page).to_not have_content /Read More/i
      end
    end
  end

  context 'contact form' do
    context 'with invalid data' do
        it 'shows inline validations' do
          within '#new_contact_form' do
            click_on 'Send'  
          end
          expect(page).to have_selector('label[for=contact_form_name]', text: 'can\'t be blank')
    
          within '#new_contact_form' do
            fill_in 'contact_form_email', with: 'not an email'
            click_on 'Send'
          end
          expect(page).to have_selector('label[for=contact_form_email]', text: 'is invalid')
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

  context 'newsletter signup' do
    context 'with invalid data' do
        it 'shows flash error' do
          within '#new_newsletter_signup' do
            click_on 'Join the Club'  
          end
          within '.flash-error' do
            expect(page).to have_content 'Failed to join newsletter. Email is invalid'
          end
    
          within '#new_newsletter_signup' do
            fill_in 'newsletter_signup_email', with: 'not an email'
            click_on 'Join the Club'
          end
          within '.flash-error' do
            expect(page).to have_content 'Failed to join newsletter. Email is invalid'
          end
        end
      end
    
      context 'with valid data' do
        it 'submits' do
          within '#new_newsletter_signup' do
            fill_in 'newsletter_signup_email', with: 'bar@foo.com'
            click_on 'Join the Club'
          end
    
          within '.flash-success' do
            expect(page).to have_content 'Thanks for joining my newsletter!'
          end
        end
      end
  end
end