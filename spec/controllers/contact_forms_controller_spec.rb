require 'rails_helper'

describe ContactFormsController do
  describe 'create' do
    context 'with valid contact form params' do
      let(:contact_form) do
        {
          contact_form: {
            name: 'Ben',
            email: 'ben@benradler.com',
            message: 'Test message!',
            nickname: ''
          }
        }
      end

      before :each do
        get :create, contact_form
      end

      it 'flashes success' do
        expect(controller.flash['success']).to match /email sent successfully/i
      end

      it 'redirects to contact-me' do
        expect(subject).to redirect_to page_path('contact-me')
      end
    end

    context 'with invalid contact form params' do
      let(:contact_form) do
        {
          contact_form: {
            email: 'ben',
            nickname: 'foobar'
          }
        }
      end

      before :each do
        get :create, contact_form
      end

      it 'flashes error' do
        expect(controller.flash['error']).to match /email failed to send/i
      end

      it 'redirects to contact-me' do
        expect(subject).to redirect_to page_path('contact-me')
      end
    end
  end
end
