# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Runners::CognitiveArchaeology do
  let(:engine) { Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new }
  let(:runner) { described_class }

  describe '.create_site' do
    it 'creates a site successfully' do
      result = runner.create_site(domain: :cognitive, engine: engine)
      expect(result[:success]).to be true
      expect(result[:site]).to be_a Hash
      expect(result[:site][:domain]).to eq :cognitive
    end

    it 'returns failure for invalid domain' do
      result = runner.create_site(domain: :bogus, engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to include('unknown domain')
    end
  end

  describe '.dig' do
    let(:site) { engine.create_site(domain: :cognitive) }

    it 'digs successfully' do
      result = runner.dig(site_id: site.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:dug]).to be true
      expect(result[:site]).to be_a Hash
    end

    it 'returns failure for unknown site' do
      result = runner.dig(site_id: 'bad', engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to include('site not found')
    end
  end

  describe '.excavate' do
    let(:site) { engine.create_site(domain: :cognitive) }

    it 'excavates successfully' do
      result = runner.excavate(site_id: site.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:artifact]).to be_a Hash
      expect(result[:artifact][:domain]).to eq :cognitive
    end

    it 'returns failure for unknown site' do
      result = runner.excavate(site_id: 'bad', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.restore_artifact' do
    let(:site) { engine.create_site(domain: :cognitive) }

    it 'restores an artifact' do
      artifact = engine.excavate(site_id: site.id)
      artifact.decay!(rate: 0.3)
      result = runner.restore_artifact(
        artifact_id: artifact.id, boost: 0.2, engine: engine
      )
      expect(result[:success]).to be true
      expect(result[:artifact][:preservation_quality]).to be > 0.0
    end

    it 'returns failure for unknown artifact' do
      result = runner.restore_artifact(
        artifact_id: 'bad', boost: 0.1, engine: engine
      )
      expect(result[:success]).to be false
      expect(result[:error]).to include('artifact not found')
    end
  end

  describe '.list_artifacts' do
    let(:site) { engine.create_site(domain: :cognitive) }

    before { 3.times { engine.excavate(site_id: site.id) } }

    it 'lists all artifacts' do
      result = runner.list_artifacts(engine: engine)
      expect(result[:success]).to be true
      expect(result[:count]).to eq 3
      expect(result[:artifacts]).to be_an Array
    end

    it 'filters by domain' do
      result = runner.list_artifacts(engine: engine, domain: :cognitive)
      expect(result[:count]).to eq 3
    end

    it 'filters by non-matching domain' do
      result = runner.list_artifacts(engine: engine, domain: :emotional)
      expect(result[:count]).to eq 0
    end

    it 'filters by depth_level' do
      result = runner.list_artifacts(engine: engine, depth_level: :surface)
      expect(result[:count]).to eq 3
    end
  end

  describe '.archaeology_status' do
    it 'returns status report' do
      site = engine.create_site(domain: :cognitive)
      engine.excavate(site_id: site.id)
      result = runner.archaeology_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to be_a Hash
      expect(result[:report][:total_artifacts]).to eq 1
    end

    it 'works on empty engine' do
      result = runner.archaeology_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report][:total_artifacts]).to eq 0
    end
  end
end
