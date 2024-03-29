require 'features_helper'

describe 'Custom Errors' do
  context 'when 404' do
    before do
      method = Rails.application.method(:env_config)
      # rubocop:disable RSpec/ExpectInHook
      expect(Rails.application).to receive(:env_config).with(no_args) do
        method.call.merge(
          'action_dispatch.show_exceptions' => true,
          'action_dispatch.show_detailed_exceptions' => false,
        )
      end.at_least(:once)
      # rubocop:enable RSpec/ExpectInHook
    end

    %w[/404 /not-a-real-page].each do |url|
      it 'returns appropriate status code and content' do
        visit url
        expect(page).to have_content(/404 - File Not Found/i)
      end
    end
  end

  context 'when 422' do
    it 'returns appropriate status code and content' do
      visit '/422'
      expect(page).to have_content(/422 - Unprocessable Entity/i)
    end
  end

  context 'when 500' do
    it 'returns appropriate status code and content' do
      visit '/500'
      expect(page).to have_content(/500 - Internal Server Error/i)
    end
  end
end
