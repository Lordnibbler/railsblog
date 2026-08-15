require 'features_helper'

describe '/' do
  let!(:post) { create(:post) }
  let!(:long_post) { create(:long_post, user: post.user) }
  let!(:unpublished_post) { create(:unpublished_post, user: post.user) }

  it 'renders the adaptive glass navigation and static expertise cards' do
    visit root_path

    expect(page).to have_css('.navigation-container')
    expect(page.all('button.mobile-nav-toggle', visible: :all).size).to eq(1)
    expect(page).to have_css('.mobile-nav-panel[role="dialog"]')
    expect(page).to have_css('.mobile-nav[inert][aria-hidden="true"]', visible: :all)

    within '#expertise' do
      expect(page).to have_css('.glass-card-static', count: 3)
    end

    within '#videos' do
      expect(page).to have_css('.video-glass-card.glass-panel', count: 3)
    end

    expect(page).to have_css('.newsletter-input')
    expect(page).to have_css('.newsletter-button.glass-button')
    expect(page).to have_css('.glass-footer')
  end

  context 'with JavaScript enabled', :js do
    it 'activates the liquid glass navigation after scrolling' do
      visit root_path

      expect(page).to have_css('.desktop-nav:not(.nav-liquid-glass)')

      page.execute_script('window.scrollTo(0, 200)')

      expect(page).to have_css('.desktop-nav.nav-liquid-glass')
      expect(page).to have_css(
        '.desktop-nav.nav-glass-on-dark, .desktop-nav.nav-glass-on-light',
      )
    end

    it 'opens and closes the animated mobile navigation' do
      page.current_window.resize_to(390, 844)
      visit root_path

      expect(page).to have_css('button.mobile-nav-toggle[aria-expanded="false"]', visible: :all)
      open_button = find('button[aria-label="Open navigation"]')
      open_button_rect = open_button.rect
      viewport_width = page.evaluate_script('document.documentElement.clientWidth')
      open_button.click

      expect(page).to have_css('button.mobile-nav-toggle[aria-expanded="true"]', visible: :all)
      expect(page).to have_css('.mobile-nav.mobile-nav-open')
      expect(page.evaluate_script("document.querySelector('.mobile-nav').inert")).to be(false)
      expect(page.evaluate_script('document.activeElement.textContent.trim()')).to eq('home')

      panel_rect = find('.mobile-nav-panel').rect
      panel_insets = page.evaluate_script(<<~JS)
        ['left', 'right'].map((property) =>
          getComputedStyle(document.querySelector('.mobile-nav-panel'))[property]
        )
      JS
      expect(panel_insets).to eq(%w[16px 16px])
      expect(panel_rect.width).to be > viewport_width * 0.9

      close_button = find('button[aria-label="Close navigation"]')
      expect(close_button.rect.x).to be_within(0.5).of(open_button_rect.x)
      expect(close_button.rect.y).to be_within(0.5).of(open_button_rect.y)
      close_button.click

      expect(page).to have_no_css('.mobile-nav.mobile-nav-open')
      expect(page).to have_css('button.mobile-nav-toggle[aria-expanded="false"]', visible: :all)
      expect(page.evaluate_script("document.activeElement.getAttribute('aria-label')")).to eq('Open navigation')
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
        expect(page).to have_css('article.article-glass.glass-panel')
        expect(page).to have_css('.article-author.glass-panel')
        expect(page).to have_css('nav.article-navigation[aria-label="Post navigation"]')
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
