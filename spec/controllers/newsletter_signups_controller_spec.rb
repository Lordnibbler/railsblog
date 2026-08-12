require 'rails_helper'

describe NewsletterSignupsController do
  describe 'create' do
    it 'emails a confirmation without creating a database row' do
      expect do
        post :create, params: { newsletter_signup: { email: ' Foo@Bar.com ' } }
      end.not_to change(NewsletterSignup, :count)

      expect(ActionMailer::Base.deliveries.last.to).to eq(['foo@bar.com'])
      expect(ActionMailer::Base.deliveries.last.body.encoded).to include('http://test.host/newsletter_signups/confirm')
      expect(controller.flash['success']).to match(/check your email/i)
    end

    it 'given invalid email it flashes an error' do
      post :create, params: { newsletter_signup: { email: 'nope' } }

      expect(controller.flash['error']).to match(/failed to join newsletter/i)
    end

    it 'does not send mail when the honeypot is filled in' do
      expect do
        post :create, params: { newsletter_signup: { email: 'foo@bar.com', website: 'spam.example' } }
      end.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end

  describe 'confirm' do
    it 'creates the signup from a valid token' do
      token = Rails.application.message_verifier(:newsletter_signup).generate(
        'foo@bar.com', expires_in: 24.hours, purpose: :newsletter_signup,
      )

      expect { get :confirm, params: { token: token } }.to change(NewsletterSignup, :count).by(1)

      expect(NewsletterSignup.last.email).to eq('foo@bar.com')
      expect(controller.flash['success']).to match(/has been confirmed/i)
    end

    it 'rejects an invalid token' do
      expect { get :confirm, params: { token: 'invalid' } }.not_to change(NewsletterSignup, :count)

      expect(controller.flash['error']).to match(/invalid or has expired/i)
    end
  end
end
