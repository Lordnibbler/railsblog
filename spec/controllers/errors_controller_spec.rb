require 'rails_helper'

describe ErrorsController do
  context 'when file_not_found' do
    it 'returns 404' do
      get :file_not_found
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when unprocessable_entity' do
    it 'returns 404' do
      get :unprocessable_entity
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'when internal_server_error' do
    it 'returns 404' do
      get :internal_server_error
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
