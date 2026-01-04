require 'rails_helper'

RSpec.describe ContactForm do
  describe 'validations' do
    it 'is valid with required attributes' do
      form = described_class.new(
        name: 'Ben',
        email: 'ben@benradler.com',
        message: 'Hello!',
        nickname: ''
      )

      expect(form).to be_valid
    end

    it 'is invalid with a bad email' do
      form = described_class.new(
        name: 'Ben',
        email: 'not-an-email',
        message: 'Hello!',
        nickname: ''
      )

      expect(form).not_to be_valid
      expect(form.errors[:email]).not_to be_empty
    end

    it 'rejects the honeypot field when present' do
      form = described_class.new(
        name: 'Ben',
        email: 'ben@benradler.com',
        message: 'Hello!',
        nickname: 'spammy'
      )

      expect(form).not_to be_valid
    end
  end

  describe '#headers' do
    it 'builds the expected email headers' do
      form = described_class.new(
        name: 'Ben',
        email: 'ben@benradler.com',
        message: 'Hello!',
        nickname: ''
      )

      headers = form.headers
      expect(headers[:subject]).to eq('Contact Form from Ben at benradler.com')
      expect(headers[:to]).to eq('ben@benradler.com')
      expect(headers[:from]).to eq('ben@benradler.com')
      expect(headers[:reply_to]).to eq('"Ben" <ben@benradler.com>')
    end
  end
end
