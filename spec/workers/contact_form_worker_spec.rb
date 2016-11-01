require 'rails_helper'

describe ContactFormWorker do
  subject(:deliver_form) { described_class.new.perform(params) }

  describe '#perform' do
    context 'when ContactForm is valid' do
      let(:fake_request) { instance_double(ActionDispatch::Request).as_null_object }
      let(:params) do
        {
          name: 'Ben',
          email: 'ben@benradler.com',
          message: 'Test message!',
          nickname: '',
          request: fake_request
        }
      end

      it 'delivers the form' do
        expect(deliver_form).to be_truthy
      end
    end

    context 'when ContactForm is invalid' do
      let(:params) do
        {
          email: 'ben',
          nickname: 'foobar'
        }
      end

      it 'does not deliver the form' do
        expect(deliver_form).to be_falsy
      end
    end
  end
end
