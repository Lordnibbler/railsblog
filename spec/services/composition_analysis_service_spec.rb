require 'rails_helper'

describe CompositionAnalysisService do
  let(:photo) do
    FlickrPhoto.create!(
      flickr_id: 'photo-1', display_position: 1,
      photo_data: {
        title: 'Crosswalk', description: 'A person crossing',
        photo_large: { url: 'https://example.com/photo.jpg' },
      },
    )
  end
  let(:analysis) do
    {
      summary: 'A diagonal curb directs attention to an isolated pedestrian.',
      techniques: [{
        key: 'leading', confidence: 0.91, title: 'The curb carries the eye',
        explanation: 'The visible curb runs directly toward the pedestrian.',
        points: [{ x: 5, y: 88 }, { x: 63, y: 44 }], region: { x: 2, y: 38, width: 66, height: 55 },
      }],
    }
  end
  let(:requests) { [] }
  let(:client) { instance_double(Net::HTTP) }
  let(:http) { class_double(Net::HTTP) }

  def response
    Net::HTTPOK.new('1.1', '200', 'OK').tap do |result|
      result.instance_variable_set(:@read, true)
      result.body = JSON.generate(output: [{ content: [{ type: 'output_text', text: JSON.generate(analysis) }] }])
    end
  end

  before do
    allow(client).to receive(:request) do |request|
      requests << request
      response
    end
    allow(http).to receive(:start).and_yield(client)
    stub_const('ENV', ENV.to_h.merge('OPENAI_API_KEY' => 'test-key'))
  end

  it 'sends the photograph to the Responses API and persists its structured reading' do
    expect(described_class.new(photo, http:).analyze_and_persist).to be(true)

    persisted = photo.reload.composition_analysis
    expect(persisted).to include(
      'summary' => analysis[:summary],
      'image_flickr_id' => 'photo-1',
      'analysis_version' => described_class::VERSION,
      'api_model' => 'gpt-5-mini',
      'api_usage' => {},
    )
    expect(persisted.dig('techniques', 0, 'classification_id')).to eq('flickr:photo-1:leading')
    expect(photo.composition_analysis_version).to eq(described_class::VERSION)
    expect(photo.composition_analyzed_at).to be_present
    request = requests.first
    payload = JSON.parse(request.body)
    expect(payload.dig('input', 0, 'content', 1, 'image_url')).to eq('https://example.com/photo.jpg')
    expect(payload.dig('text', 'format', 'type')).to eq('json_schema')
    points_schema = payload.dig(
      'text', 'format', 'schema', 'properties', 'techniques', 'items', 'properties', 'points',
    )
    expect(points_schema.fetch('minItems')).to eq(1)
    technique_enum = payload.dig(
      'text', 'format', 'schema', 'properties', 'techniques', 'items', 'properties', 'key', 'enum',
    )
    expect(technique_enum).to include(
      'frame', 'symmetry', 'juxtaposition', 'color', 'diagonal',
    )
    expect(request['Authorization']).to eq('Bearer test-key')
  end

  it 'records failures without replacing an existing analysis' do
    photo.update!(composition_analysis: { summary: 'Photographer approved' })
    allow(client).to receive(:request).and_raise(Net::ReadTimeout)

    expect(described_class.new(photo, http:).analyze_and_persist).to be(false)
    expect(photo.reload.composition_analysis).to eq('summary' => 'Photographer approved')
    expect(photo.composition_analysis_error).to include('Net::ReadTimeout')
  end

  # The outer API-response fixtures remain available while this block exercises
  # selection behavior, so the inherited helper count is intentionally higher.
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '.analyze_pending' do
    let(:analyzer) { instance_double(described_class, analyze_and_persist: true) }
    let!(:previously_analyzed) do
      FlickrPhoto.create!(
        flickr_id: 'photo-2', display_position: 2, photo_data: {},
        composition_analysis: { summary: 'Stored paid result' }, composition_analysis_version: 'older-version',
      )
    end

    before do
      photo
      allow(described_class).to receive(:new).and_return(analyzer)
    end

    it 'only analyzes photographs with no stored result by default' do
      expect(described_class.analyze_pending).to eq(1)

      expect(described_class).to have_received(:new).with(photo).once
      expect(described_class).not_to have_received(:new).with(previously_analyzed)
    end

    it 'reanalyzes stored results only when force is explicit' do
      expect(described_class.analyze_pending(force: true)).to eq(2)

      expect(described_class).to have_received(:new).with(photo).once
      expect(described_class).to have_received(:new).with(previously_analyzed).once
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
