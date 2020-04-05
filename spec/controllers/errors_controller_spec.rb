require 'rails_helper'

describe ErrorsController do
  context 'file_not_found' do
    it 'returns 404' do
      get :file_not_found
      expect(response.code).to eql('404')
    end
  end

  context 'unprocessable_entity' do
    it 'returns 404' do
      get :unprocessable_entity
      expect(response.code).to eql('422')
    end
  end

  context 'internal_server_error' do
    it 'returns 404' do
      get :internal_server_error
      expect(response.code).to eql('500')
    end
  end
end
