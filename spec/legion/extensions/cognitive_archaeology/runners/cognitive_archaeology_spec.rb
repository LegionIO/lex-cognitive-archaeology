# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Runners::CognitiveArchaeology do
  let(:engine) { Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new }
  let(:runner) { Object.new.extend(described_class) }

  def make_site
    runner.create_site(domain: :cognitive, engine: engine)
  end

  describe '#create_site' do
    it 'returns success' do
      expect(make_site[:success]).to be true
    end

    it 'returns site data' do
      expect(make_site[:site][:domain]).to eq(:cognitive)
    end
  end

  describe '#dig' do
    it 'advances depth' do
      s = make_site
      result = runner.dig(site_id: s[:site][:id], engine: engine)
      expect(result[:dug]).to be true
    end

    it 'fails for unknown site' do
      expect(runner.dig(site_id: 'bad', engine: engine)[:success]).to be false
    end
  end

  describe '#excavate' do
    it 'returns artifact data' do
      s = make_site
      r = runner.excavate(site_id: s[:site][:id], engine: engine)
      expect(r[:artifact][:type]).to be_a(Symbol)
    end
  end

  describe '#restore_artifact' do
    it 'restores' do
      s = make_site
      e = runner.excavate(site_id: s[:site][:id], engine: engine)
      r = runner.restore_artifact(artifact_id: e[:artifact][:id], engine: engine)
      expect(r[:success]).to be true
    end
  end

  describe '#list_artifacts' do
    it 'returns all artifacts' do
      s = make_site
      runner.excavate(site_id: s[:site][:id], engine: engine)
      expect(runner.list_artifacts(engine: engine)[:count]).to eq(1)
    end
  end

  describe '#archaeology_status' do
    it 'returns report' do
      expect(runner.archaeology_status(engine: engine)[:report][:total_artifacts]).to eq(0)
    end
  end
end
