require 'rails_helper'

describe PagesController do
  describe '#show' do
    %w[contact-me squarecrusher/privacy-policy].each do |page|
      context "when GET to #{page}" do
        before do
          get :show, params: { id: page }
        end

        it 'responds with success' do
          expect(response).to have_http_status(:success)
          expect(response).to have_http_status(:ok)
        end

        it { is_expected.to render_template(:application) }
        it { is_expected.to render_template(page) }

        it 'sets body class' do
          expect(assigns(:body_class)).to eq('static-page-template')
        end
      end
    end
  end
end
