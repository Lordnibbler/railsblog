require 'features_helper'

describe 'Custom Errors' do
  context '404' do
    # @todo test invalid route via comment in http://thepugautomatic.com/2014/08/404-with-rails-4/
    it 'returns appropriate status code and content' do
      visit '/404'
      expect(page.status_code).to eql 404
      expect(page).to have_content '404 - File Not Found'
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
