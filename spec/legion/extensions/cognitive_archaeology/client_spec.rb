# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::CognitiveArchaeology::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    expect(client).to respond_to(:bury_artifact)
    expect(client).to respond_to(:excavate)
    expect(client).to respond_to(:survey)
    expect(client).to respond_to(:date_artifact)
    expect(client).to respond_to(:restore_artifact)
    expect(client).to respond_to(:catalog_artifact)
    expect(client).to respond_to(:cross_reference)
    expect(client).to respond_to(:deepest_artifacts)
    expect(client).to respond_to(:surface_finds)
    expect(client).to respond_to(:excavation_report)
  end

  it 'accepts an injected engine' do
    engine = Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new
    c = described_class.new(engine: engine)
    c.bury_artifact(content: 'sherd', domain: 'ceramic', stratum_depth: 3)
    expect(engine.strata).not_to be_empty
  end

  it 'round-trips a full artifact lifecycle' do
    buried = client.bury_artifact(content: 'bronze fibula', domain: 'jewelry',
                                  stratum_depth: 6, artifact_type: :structure,
                                  preservation_quality: 0.6)
    expect(buried[:success]).to be true
    artifact_id = buried[:id]

    dated = client.date_artifact(artifact_id: artifact_id)
    expect(dated[:success]).to be true
    expect(dated[:stratum_depth]).to eq(6)

    restored = client.restore_artifact(artifact_id: artifact_id)
    expect(restored[:success]).to be true
    expect(restored[:preservation_quality]).to be > 0.6

    cataloged = client.catalog_artifact(artifact_id: artifact_id)
    expect(cataloged[:success]).to be true

    excavated = client.excavate(stratum_depth: 6)
    expect(excavated[:count]).to eq(1)

    report = client.excavation_report
    expect(report[:total_artifacts]).to eq(1)
  end
end
