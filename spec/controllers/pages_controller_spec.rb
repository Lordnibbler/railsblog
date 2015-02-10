require 'rails_helper'

describe HighVoltage::PagesController, '#show' do
  %w(contact-me).each do |page|
    context 'on GET to #{page}' do
      before do
        get :show, id: page
      end

      it 'responds with success' do
        expect(response).to be_succes
        expect(response.code).to eql('200')
      end

      it { should render_template(:application) }
      it { should render_template(page) }
    end
  end
end
