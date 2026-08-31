require 'rails_helper'

RSpec.describe Api::V1::OperationsController do
  describe 'GET #index' do
    it 'returns CircleCI workflow details used by deployment history' do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('CIRCLECI_TOKEN', nil).and_return('read-token')
      allow(ENV).to receive(:fetch).with('CIRCLECI_BRANCH', 'master').and_return('master')
      allow(controller).to receive(:request_json).and_return(
        'items' => [{
          'id' => 'workflow-id', 'duration' => 127, 'status' => 'success',
          'created_at' => '2026-08-15T12:00:00Z', 'stopped_at' => '2026-08-15T12:02:07Z',
          'branch' => 'master', 'credits_used' => 42,
        }],
      )

      get :index

      run = response.parsed_body.dig('circleci', 'runs', 0)
      expect(run).to include(
        'id' => 'workflow-id', 'status' => 'success', 'stopped_at' => '2026-08-15T12:02:07Z',
        'branch' => 'master', 'credits_used' => 42,
      )
    end
  end
end
