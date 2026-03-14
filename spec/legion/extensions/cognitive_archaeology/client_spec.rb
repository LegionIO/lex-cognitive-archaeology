# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Client do
  let(:engine) { Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new }
  let(:client) { described_class.new(engine: engine) }
  let(:mod)    { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }

  describe '#initialize' do
    it 'creates a client without arguments' do
      expect { described_class.new }.not_to raise_error
    end

    it 'accepts an engine keyword argument' do
      expect { described_class.new(engine: engine) }.not_to raise_error
    end

    it 'uses provided engine' do
      site   = engine.create_site(domain: :cognitive)
      result = client.create_site(domain: :cognitive)
      expect(result[:success]).to be true
      expect(engine.all_sites.size).to be >= 1
      _ = site
    end
  end

  describe '#create_site' do
    it 'returns success: true with site data' do
      result = client.create_site(domain: :cognitive)
      expect(result[:success]).to be true
      expect(result[:site]).to be_a(Hash)
    end

    it 'returns success: false for invalid domain' do
      result = client.create_site(domain: :invalid)
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    mod::DOMAIN_TYPES.each do |d|
      it "creates a site for domain :#{d}" do
        expect(client.create_site(domain: d)[:success]).to be true
      end
    end
  end

  describe '#dig' do
    let(:site_id) { client.create_site(domain: :cognitive)[:site][:id] }

    it 'returns success: true' do
      expect(client.dig(site_id: site_id)[:success]).to be true
    end

    it 'includes :dug key' do
      expect(client.dig(site_id: site_id)).to have_key(:dug)
    end

    it 'returns success: false for unknown site_id' do
      result = client.dig(site_id: 'bad-id')
      expect(result[:success]).to be false
    end
  end

  describe '#excavate' do
    let(:site_id) { client.create_site(domain: :cognitive)[:site][:id] }

    it 'returns success: true with artifact data' do
      result = client.excavate(site_id: site_id)
      expect(result[:success]).to be true
      expect(result[:artifact]).to be_a(Hash)
    end

    it 'artifact has expected keys' do
      artifact = client.excavate(site_id: site_id)[:artifact]
      expect(artifact).to have_key(:id)
      expect(artifact).to have_key(:type)
      expect(artifact).to have_key(:preservation)
    end

    it 'returns success: false for unknown site_id' do
      expect(client.excavate(site_id: 'x')[:success]).to be false
    end
  end

  describe '#restore_artifact' do
    let!(:artifact_id) do
      site_id = client.create_site(domain: :cognitive)[:site][:id]
      client.excavate(site_id: site_id)[:artifact][:id]
    end

    it 'returns success: true' do
      expect(client.restore_artifact(artifact_id: artifact_id)[:success]).to be true
    end

    it 'includes artifact data' do
      expect(client.restore_artifact(artifact_id: artifact_id)[:artifact]).to be_a(Hash)
    end

    it 'returns success: false for unknown artifact_id' do
      expect(client.restore_artifact(artifact_id: 'ghost')[:success]).to be false
    end
  end

  describe '#list_artifacts' do
    before do
      site_id = client.create_site(domain: :cognitive)[:site][:id]
      3.times { client.excavate(site_id: site_id) }
    end

    it 'returns success: true with artifacts array' do
      result = client.list_artifacts
      expect(result[:success]).to be true
      expect(result[:artifacts]).to be_an(Array)
    end

    it 'returns correct count' do
      expect(client.list_artifacts[:count]).to eq(3)
    end

    it 'filters by domain' do
      result = client.list_artifacts(domain: :cognitive)
      expect(result[:artifacts].map { |a| a[:domain] }.uniq).to eq([:cognitive])
    end

    it 'filters by depth_level' do
      result = client.list_artifacts(depth_level: :surface)
      expect(result[:artifacts].map { |a| a[:depth_level] }.uniq).to eq([:surface])
    end

    it 'returns empty array when no artifacts match type filter' do
      result = client.list_artifacts(type: :belief)
      expect(result[:artifacts]).to be_an(Array)
    end
  end

  describe '#archaeology_status' do
    it 'returns success: true with report' do
      result = client.archaeology_status
      expect(result[:success]).to be true
      expect(result[:report]).to be_a(Hash)
    end

    it 'report includes total_artifacts' do
      expect(client.archaeology_status[:report]).to have_key(:total_artifacts)
    end

    it 'report includes total_sites' do
      expect(client.archaeology_status[:report]).to have_key(:total_sites)
    end
  end
end
