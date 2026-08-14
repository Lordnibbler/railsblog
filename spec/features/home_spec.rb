require 'features_helper'

describe '/' do
  let!(:post) { create(:post) }
  let!(:long_post) { create(:long_post, user: post.user) }
  let!(:unpublished_post) { create(:unpublished_post, user: post.user) }

  it 'renders the adaptive glass navigation and static expertise cards' do
    visit root_path

    expect(page).to have_css('.navigation-container')
    expect(page).to have_css('button[aria-label="Open navigation"]', visible: :all)
    expect(page).to have_css('button[aria-label="Close navigation"]', visible: :all)
    expect(page).to have_css('.mobile-nav-panel[role="dialog"]')

    within '#expertise' do
      expect(page).to have_css('.glass-card-static', count: 3)
    end
  end

  context 'with JavaScript enabled', :js do
    it 'activates the liquid glass navigation after scrolling' do
      visit root_path

      expect(page).to have_no_css('.desktop-nav.nav-liquid-glass')

      page.execute_script('window.scrollTo(0, 200)')

      expect(page).to have_css('.desktop-nav.nav-liquid-glass')
      expect(page).to have_css(
        '.desktop-nav.nav-glass-on-dark, .desktop-nav.nav-glass-on-light',
      )
    end

    it 'opens and closes the animated mobile navigation' do
      page.current_window.resize_to(390, 844)
      visit root_path

      open_button = find('button[aria-label="Open navigation"]')
      open_button.click

      expect(open_button['aria-expanded']).to eq('true')
      expect(page).to have_css('.mobile-nav.mobile-nav-open')

      find('button[aria-label="Close navigation"]').click

      expect(page).to have_no_css('.mobile-nav.mobile-nav-open')
      expect(open_button['aria-expanded']).not_to eq('true')
    end
  end

  context 'when blog posts exist' do
    it 'shows all published posts' do
      visit root_path

      within '#latest' do
        expect(page).to have_css('.glass-card', count: 2)
      end
    end

    context 'when clicking Continue Reading' do
      it 'shows full post' do
        visit root_path

        within '#latest' do
          page.first(:css, '.glass-card').click
        end

        expect(page).to have_content 'Spicy jalapeno bacon'
        expect(page).to have_content(/Previous Post/i)
        expect(page).to have_no_content(/Read More/i)
      end
    end
  end

  context 'when using contact form' do
    context 'with invalid data', :js do
      before { visit root_path }

      it 'shows inline validations' do
        within '#new_contact_form' do
          click_on 'Send'
        end
        expect(page).to have_css('label[for=contact_form_name]', text: 'can\'t be blank')

        within '#new_contact_form' do
          fill_in 'contact_form_email', with: 'not an email'
          click_on 'Send'
        end
        expect(page).to have_css('label[for=contact_form_email]', text: 'is invalid')
      end
    end

    context 'with valid data' do
      before { visit root_path }

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

  context 'when using newsletter signup' do
    before { visit root_path }

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
          expect(page).to have_content 'Check your email to confirm your newsletter subscription.'
        end

        expect(NewsletterSignup.where(email: 'bar@foo.com')).not_to exist
      end
    end
  end
end
