require 'rails_helper'

RSpec.describe NewsletterSignup, type: :model do
  it 'does not allow invalid emails' do
    model = NewsletterSignup.new(email: "foo")
    
    model.validate

    expect(model.errors[:email]).to eq(['is invalid'])
  end

  it 'allows valid emails' do
    model = NewsletterSignup.new(email: "foo@bar.com")

    model.validate

    expect(model.errors[:email]).to eq([])
  end
end
