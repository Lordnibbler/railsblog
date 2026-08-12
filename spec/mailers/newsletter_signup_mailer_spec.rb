require 'rails_helper'

describe NewsletterSignupMailer do
  describe 'confirmation' do
    it 'sends an expiring confirmation link to the subscriber' do
      email = described_class.confirmation(
        'foo@bar.com', host: 'staging.example.com', protocol: 'https', port: 443
      )

      expect(email.to).to eq(['foo@bar.com'])
      expect(email.subject).to eq('Confirm your newsletter subscription')
      expect(email.body.encoded).to include('https://staging.example.com/newsletter_signups/confirm')
      expect(email.body.encoded).to include('token=')
    end
  end
end
