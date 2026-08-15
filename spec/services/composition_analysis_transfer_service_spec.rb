require 'rails_helper'

describe CompositionAnalysisTransferService do
  let!(:photo) do
    FlickrPhoto.create!(
      flickr_id: 'photo-1', display_position: 1, photo_data: {},
      composition_analysis: { 'summary' => 'A stored reading' },
      composition_analysis_version: 'v2', composition_analyzed_at: Time.zone.parse('2026-08-15 10:00:00'),
    )
  end

  it 'round-trips checksummed analysis data without changing photo metadata' do
    exported = described_class.export
    photo.update!(composition_analysis: {}, composition_analysis_version: nil, composition_analyzed_at: nil)

    expect(described_class.import(exported)).to eq(1)
    expect(photo.reload.composition_analysis).to eq('summary' => 'A stored reading')
    expect(photo.composition_analysis_version).to eq('v2')
    expect(photo.photo_data).to eq({})
  end

  it 'rejects modified exports' do
    payload = JSON.parse(described_class.export)
    payload['records'][0]['composition_analysis']['summary'] = 'Tampered'

    expect { described_class.import(JSON.generate(payload)) }.to raise_error('Composition analysis checksum mismatch')
  end

  it 'rejects records that do not exist in the destination catalog' do
    exported = described_class.export
    photo.destroy!

    expect { described_class.import(exported) }.to raise_error('Missing Flickr photos: photo-1')
  end
end
