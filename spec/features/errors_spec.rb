require 'features_helper'

describe 'Custom Errors' do
  context '404' do
    before do
      method = Rails.application.method(:env_config)
      expect(Rails.application).to receive(:env_config).with(no_args()) do
        method.call.merge(
          'action_dispatch.show_exceptions' => true,
          'action_dispatch.show_detailed_exceptions' => false
        )
      end
    end

    %w(/404 /not-a-real-page).each do |url|
      it 'returns appropriate status code and content' do
        visit url
        expect(page.status_code).to eql 404
        expect(page).to have_content '404 - File Not Found'
      end
    end
  end

  context '422' do
    it 'returns appropriate status code and content' do
      visit '/422'
      expect(page.status_code).to eql 422
      expect(page).to have_content '422 - Unprocessable Entity'
    end
  end

  context '500' do
    it 'returns appropriate status code and content' do
      visit '/500'
      expect(page.status_code).to eql 500
      expect(page).to have_content '500 - Internal Server Error'
    end
  end
end
