require 'rails_helper'

RSpec.describe NewsletterSignup do
  it 'does not allow invalid emails' do
    model = described_class.new(email: 'foo')

    model.validate

    expect(model.errors[:email]).to eq(['is invalid'])
  end

  it 'allows valid emails' do
    # TODO: get rid of fixtures
    model = described_class.new(email: 'foo@baz.com')

    model.validate

    expect(model.errors[:email]).to eq([])
  end
end
