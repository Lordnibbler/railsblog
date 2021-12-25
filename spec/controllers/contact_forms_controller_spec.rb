require 'rails_helper'

describe ContactFormsController do
  describe 'POST #create' do
    subject(:post_create) { post :create, params: contact_form }

    before { post_create }

    context 'with valid contact form params' do
      let(:contact_form) do
        {
          contact_form: {
            name: 'Ben',
            email: 'ben@benradler.com',
            message: 'Test message!',
            nickname: '',
          },
        }
      end

      it 'flashes success' do
        expect(controller.flash['success']).to match(/email sent successfully/i)
      end

      it 'redirects to contact-me' do
        expect(subject).to redirect_to page_path('contact-me')
      end

      context 'when contact form is submitted from homepage' do
        it 'redirects to homepage' do
          contact_form[:request_route] = root_path

          expect(post(:create, params: contact_form)).to redirect_to(root_path)
        end
      end
    end

    context 'with invalid contact form params' do
      let(:contact_form) do
        {
          contact_form: {
            email: 'ben',
            nickname: 'foobar',
          },
        }
      end

      it 'flashes error' do
        expect(controller.flash['error']).to match(/email failed to send/i)
      end

      it 'redirects to contact-me' do
        expect(subject).to redirect_to page_path('contact-me')
      end
    end
  end
end
