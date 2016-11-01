require 'rails_helper'

describe ContactFormsController do
  describe 'GET #create' do
    subject(:get_create) { get :create, params: contact_form }

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

      it 'invokes the worker' do
        expect(ContactFormWorker).to receive(:perform_async).and_call_original
        get_create
      end

      it 'flashes success' do
        get_create
        expect(controller.flash['success']).to match(/email sent successfully/i)
      end

      it 'redirects to contact-me' do
        get_create
        expect(subject).to redirect_to page_path('contact-me')
      end
    end
  end
end
