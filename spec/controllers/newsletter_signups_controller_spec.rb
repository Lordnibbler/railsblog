require 'rails_helper'

describe NewsletterSignupsController do
    fixtures :newsletter_signups

    let(:signup) { newsletter_signups(:signup) }
  
    describe 'create' do
        it 'given valid email it signs up and flashes a success' do
            allow(NewsletterSignup).to receive(:create).and_return(signup)
            post :create, params: { newsletter_signup: { email: "foo@bar.com" } }

            expect(controller.flash['success']).to match(/thanks for joining my newsletter/i)
        end

        it 'given invalid email it flashes an error' do
            post :create, params: { newsletter_signup: { email: "nope" } }

            expect(controller.flash['error']).to match(/failed to join newsletter/i)
        end
    end
end
