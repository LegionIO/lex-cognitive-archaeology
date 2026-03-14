# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine do
  let(:mod)    { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }
  let(:engine) { described_class.new }

  def make_site(domain: :cognitive)
    engine.create_site(domain: domain)
  end

  def dig_to(site, depth)
    target_idx = mod::EXCAVATION_DEPTH_LEVELS.index(depth)
    current_idx = mod::EXCAVATION_DEPTH_LEVELS.index(site.current_depth)
    (target_idx - current_idx).times { engine.dig(site_id: site.id) }
  end

  describe '#create_site' do
    it 'returns an ExcavationSite' do
      expect(make_site).to be_a(Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite)
    end

    it 'stores the site internally' do
      site = make_site
      expect(engine.all_sites).to include(site)
    end

    it 'raises ArgumentError for invalid domain' do
      expect { engine.create_site(domain: :invalid_domain) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when site capacity is reached' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_SITES', 2)
      engine.create_site(domain: :cognitive)
      engine.create_site(domain: :emotional)
      expect { engine.create_site(domain: :semantic) }.to raise_error(ArgumentError, /capacity/)
    end

    mod::DOMAIN_TYPES.each do |d|
      it "creates a site for domain :#{d}" do
        expect { engine.create_site(domain: d) }.not_to raise_error
      end
    end
  end

  describe '#dig' do
    it 'returns a hash with :site and :dug keys' do
      site   = make_site
      result = engine.dig(site_id: site.id)
      expect(result).to have_key(:site)
      expect(result).to have_key(:dug)
    end

    it 'advances the site depth' do
      site = make_site
      engine.dig(site_id: site.id)
      expect(site.current_depth).to eq(:shallow)
    end

    it 'returns dug: true when successful' do
      site = make_site
      expect(engine.dig(site_id: site.id)[:dug]).to be true
    end

    it 'returns dug: false at bedrock' do
      site = make_site
      dig_to(site, :bedrock)
      expect(engine.dig(site_id: site.id)[:dug]).to be false
    end

    it 'raises ArgumentError for unknown site_id' do
      expect { engine.dig(site_id: 'no-such-id') }.to raise_error(ArgumentError, /site not found/)
    end
  end

  describe '#excavate' do
    it 'returns an Artifact' do
      site = make_site
      expect(engine.excavate(site_id: site.id)).to \
        be_a(Legion::Extensions::CognitiveArchaeology::Helpers::Artifact)
    end

    it 'stores the artifact internally' do
      site     = make_site
      artifact = engine.excavate(site_id: site.id)
      expect(engine.all_artifacts).to include(artifact)
    end

    it 'raises ArgumentError for unknown site_id' do
      expect { engine.excavate(site_id: 'nope') }.to raise_error(ArgumentError, /site not found/)
    end

    it 'raises ArgumentError when artifact capacity is reached' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_ARTIFACTS', 1)
      site = make_site
      engine.excavate(site_id: site.id)
      site2 = engine.create_site(domain: :emotional)
      expect { engine.excavate(site_id: site2.id) }.to raise_error(ArgumentError, /capacity/)
    end
  end

  describe '#restore_artifact' do
    it 'increases artifact preservation' do
      site     = make_site
      artifact = engine.excavate(site_id: site.id)
      artifact.preservation = 0.4
      engine.restore_artifact(artifact_id: artifact.id, boost: 0.2)
      expect(artifact.preservation).to be > 0.4
    end

    it 'returns the artifact' do
      site     = make_site
      artifact = engine.excavate(site_id: site.id)
      result   = engine.restore_artifact(artifact_id: artifact.id)
      expect(result).to be(artifact)
    end

    it 'raises ArgumentError for unknown artifact_id' do
      expect { engine.restore_artifact(artifact_id: 'ghost') }.to raise_error(ArgumentError, /artifact not found/)
    end
  end

  describe '#decay_all!' do
    it 'decreases preservation on all artifacts' do
      site = make_site
      3.times { engine.excavate(site_id: site.id) }
      engine.all_artifacts.each { |a| a.preservation = 0.8 }
      engine.decay_all!
      engine.all_artifacts.each do |a|
        expect(a.preservation).to be < 0.8
      end
    end

    it 'returns the count of remaining artifacts' do
      site = make_site
      3.times { engine.excavate(site_id: site.id) }
      result = engine.decay_all!
      expect(result).to be_a(Integer)
    end

    it 'prunes artifacts with preservation 0.0' do
      site     = make_site
      artifact = engine.excavate(site_id: site.id)
      artifact.preservation = 0.0
      engine.decay_all!
      expect(engine.all_artifacts).not_to include(artifact)
    end
  end

  describe '#artifacts_by_type' do
    it 'returns artifacts matching type' do
      site = make_site
      allow_any_instance_of(
        Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite
      ).to receive(:weighted_random_type).and_return(:pattern)
      engine.excavate(site_id: site.id)
      results = engine.artifacts_by_type(:pattern)
      expect(results).not_to be_empty
      expect(results.map(&:type).uniq).to eq([:pattern])
    end
  end

  describe '#artifacts_by_domain' do
    it 'returns only artifacts with matching domain' do
      site = make_site(domain: :emotional)
      engine.excavate(site_id: site.id)
      results = engine.artifacts_by_domain(:emotional)
      expect(results.map(&:domain).uniq).to eq([:emotional])
    end
  end

  describe '#artifacts_by_depth' do
    it 'returns only artifacts at matching depth' do
      site = make_site
      engine.excavate(site_id: site.id)
      results = engine.artifacts_by_depth(:surface)
      expect(results.map(&:depth_level).uniq).to eq([:surface])
    end
  end

  describe '#best_preserved' do
    it 'returns artifacts sorted by descending preservation' do
      site = make_site
      3.times { engine.excavate(site_id: site.id) }
      results = engine.best_preserved
      preservations = results.map(&:preservation)
      expect(preservations).to eq(preservations.sort.reverse)
    end

    it 'respects the limit option' do
      site = make_site
      5.times { engine.excavate(site_id: site.id) }
      expect(engine.best_preserved(limit: 2).size).to be <= 2
    end
  end

  describe '#most_fragile' do
    it 'returns only fragment artifacts' do
      site     = make_site
      artifact = engine.excavate(site_id: site.id)
      artifact.preservation = 0.1
      results = engine.most_fragile
      expect(results).to include(artifact)
    end

    it 'excludes well-preserved artifacts' do
      site     = make_site
      artifact = engine.excavate(site_id: site.id)
      artifact.preservation = 0.9
      expect(engine.most_fragile).not_to include(artifact)
    end
  end

  describe '#site_report' do
    it 'returns the site hash' do
      site = make_site
      expect(engine.site_report(site_id: site.id)).to have_key(:id)
    end

    it 'raises ArgumentError for unknown site' do
      expect { engine.site_report(site_id: 'bad') }.to raise_error(ArgumentError)
    end
  end

  describe '#archaeology_report' do
    subject(:report) { engine.archaeology_report }

    it 'includes :total_artifacts' do
      expect(report).to have_key(:total_artifacts)
    end

    it 'includes :total_sites' do
      expect(report).to have_key(:total_sites)
    end

    it 'includes :type_breakdown' do
      expect(report[:type_breakdown]).to be_a(Hash)
    end

    it 'includes :domain_breakdown' do
      expect(report[:domain_breakdown]).to be_a(Hash)
    end

    it 'includes :depth_breakdown' do
      expect(report[:depth_breakdown]).to be_a(Hash)
    end

    it 'includes :avg_preservation' do
      expect(report[:avg_preservation]).to be_a(Numeric)
    end

    it 'includes :avg_integrity' do
      expect(report[:avg_integrity]).to be_a(Numeric)
    end

    it 'includes :fragment_count' do
      expect(report).to have_key(:fragment_count)
    end

    it 'includes :ancient_count' do
      expect(report).to have_key(:ancient_count)
    end

    it 'includes :sites array' do
      expect(report[:sites]).to be_an(Array)
    end

    it 'returns 0 avg_preservation when empty' do
      expect(report[:avg_preservation]).to eq(0.0)
    end

    it 'counts artifacts correctly' do
      site = make_site
      3.times { engine.excavate(site_id: site.id) }
      expect(engine.archaeology_report[:total_artifacts]).to eq(3)
    end
  end

  describe '#all_artifacts / #all_sites' do
    it 'returns empty arrays initially' do
      expect(engine.all_artifacts).to eq([])
      expect(engine.all_sites).to eq([])
    end

    it 'returns populated arrays after operations' do
      site = make_site
      engine.excavate(site_id: site.id)
      expect(engine.all_sites.size).to eq(1)
      expect(engine.all_artifacts.size).to eq(1)
    end
  end
end
