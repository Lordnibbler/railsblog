require 'rails_helper'

describe PagesController, '#show' do
  %w[contact-me squarecrusher/privacy-policy].each do |page|
    context "on GET to #{page}" do
      before do
        get :show, params: { id: page }
      end

      it 'responds with success' do
        expect(response).to have_http_status(:success)
        expect(response.code).to eql('200')
      end

      it { should render_template(:application) }
      it { should render_template(page) }

      it 'sets body class' do
        expect(assigns(:body_class)).to eq("static-page-template")
      end
    end
  end
end
