# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Client do
  let(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:create_site, :dig, :excavate, :restore_artifact,
                                 :list_artifacts, :archaeology_status)
  end

  it 'accepts injected engine' do
    engine = Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new
    c = described_class.new(engine: engine)
    c.create_site(domain: :cognitive)
    expect(engine.all_sites.size).to eq(1)
  end

  it 'round-trips lifecycle' do
    site = client.create_site(domain: :cognitive)
    expect(site[:success]).to be true

    client.dig(site_id: site[:site][:id])

    excavated = client.excavate(site_id: site[:site][:id])
    expect(excavated[:success]).to be true

    restored = client.restore_artifact(artifact_id: excavated[:artifact][:id])
    expect(restored[:success]).to be true

    status = client.archaeology_status
    expect(status[:report][:total_artifacts]).to eq(1)
  end
end
