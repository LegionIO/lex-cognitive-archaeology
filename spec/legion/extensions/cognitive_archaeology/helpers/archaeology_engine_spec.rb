# frozen_string_literal: true
RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine do
  subject(:engine) { described_class.new }
  let(:C) { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }

  describe '#create_site' do
    it 'returns ExcavationSite' do expect(engine.create_site(domain: :cognitive)).to be_a(Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite) end
    it 'stores site' do s = engine.create_site(domain: :cognitive); expect(engine.all_sites).to include(s) end
    it 'accepts all domain types' do C::DOMAIN_TYPES.each { |d| expect(engine.create_site(domain: d).domain).to eq(d) } end
    it 'raises at max capacity' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_SITES', 1)
      engine.create_site(domain: :cognitive)
      expect { engine.create_site(domain: :emotional) }.to raise_error(ArgumentError, /max site capacity/)
    end
  end

  describe '#dig' do
    let(:site) { engine.create_site(domain: :cognitive) }
    it 'returns success' do r = engine.dig(site_id: site.id); expect(r[:success]).to be true; expect(r[:new_depth]).to eq(:shallow) end
    it 'reaches bedrock' do 4.times { engine.dig(site_id: site.id) }; r = engine.dig(site_id: site.id); expect(r[:new_depth]).to eq(:bedrock) end
    it 'fails at bedrock' do 5.times { engine.dig(site_id: site.id) }; r = engine.dig(site_id: site.id); expect(r[:success]).to be false; expect(r[:reason]).to eq(:already_at_bedrock) end
    it 'fails for unknown site' do expect(engine.dig(site_id: 'x')[:success]).to be false end
    it 'includes depth_label' do expect(engine.dig(site_id: site.id)[:depth_label]).to be_a(String) end
  end

  describe '#excavate' do
    let(:site) { engine.create_site(domain: :cognitive) }
    it 'returns success with artifact_id' do r = engine.excavate(site_id: site.id); expect(r[:success]).to be true; expect(r[:artifact_id]).to be_a(String) end
    it 'stores artifact' do r = engine.excavate(site_id: site.id); expect(engine.all_artifacts.map(&:id)).to include(r[:artifact_id]) end
    it 'returns type domain depth_level' do r = engine.excavate(site_id: site.id); expect(r[:type]).to be_a(Symbol); expect(r[:domain]).to eq(:cognitive); expect(r[:depth_level]).to eq(:surface) end
    it 'fails for unknown site' do expect(engine.excavate(site_id: 'x')[:success]).to be false end
    it 'raises at max artifacts' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_ARTIFACTS', 1)
      engine.excavate(site_id: site.id)
      expect { engine.excavate(site_id: site.id) }.to raise_error(ArgumentError, /max artifact capacity/)
    end
  end

  describe '#restore_artifact' do
    let(:site) { engine.create_site(domain: :cognitive) }
    let(:artifact_id) { engine.excavate(site_id: site.id)[:artifact_id] }
    let(:artifact) { engine.all_artifacts.find { |a| a.id == artifact_id } }

    it 'restores preservation' do artifact.preservation = 0.3; r = engine.restore_artifact(artifact_id: artifact_id); expect(r[:success]).to be true; expect(r[:preservation]).to be > 0.3 end
    it 'uses custom boost' do artifact.preservation = 0.4; engine.restore_artifact(artifact_id: artifact_id, boost: 0.3); expect(artifact.preservation).to be_within(0.001).of(0.7) end
    it 'fails for unknown artifact' do expect(engine.restore_artifact(artifact_id: 'x')[:success]).to be false end
    it 'reports well_preserved' do artifact.preservation = 0.9; expect(engine.restore_artifact(artifact_id: artifact_id)[:well_preserved]).to be true end
  end

  describe '#decay_all!' do
    let(:site) { engine.create_site(domain: :cognitive) }
    before { 3.times { engine.excavate(site_id: site.id) } }
    it 'returns success with decayed count' do r = engine.decay_all!; expect(r[:success]).to be true; expect(r[:decayed]).to eq(3) end
    it 'reduces all preservations' do before = engine.all_artifacts.map(&:preservation); engine.decay_all!; expect(engine.all_artifacts.map(&:preservation).sum).to be < before.sum end
    it 'prunes zero-preservation artifacts' do engine.all_artifacts.each { |a| a.preservation = 0.0 }; engine.decay_all!; expect(engine.all_artifacts).to be_empty end
  end

  it 'artifacts_by_domain filters correctly' do
    s1 = engine.create_site(domain: :cognitive); s2 = engine.create_site(domain: :emotional)
    engine.excavate(site_id: s1.id); engine.excavate(site_id: s2.id)
    expect(engine.artifacts_by_domain(:cognitive)).to all(satisfy { |a| a.domain == :cognitive })
  end

  it 'artifacts_by_depth filters correctly' do
    site = engine.create_site(domain: :cognitive); 3.times { engine.dig(site_id: site.id) }
    engine.excavate(site_id: site.id)
    expect(engine.artifacts_by_depth(:deep)).to all(satisfy { |a| a.depth_level == :deep })
  end

  it 'best_preserved returns sorted descending' do
    site = engine.create_site(domain: :cognitive)
    3.times do |i|
      r = engine.excavate(site_id: site.id)
      engine.all_artifacts.find { |a| a.id == r[:artifact_id] }.preservation = (i + 1) * 0.2
    end
    ps = engine.best_preserved(limit: 3).map(&:preservation)
    expect(ps).to eq(ps.sort.reverse)
  end

  it 'most_fragile returns sorted ascending' do
    site = engine.create_site(domain: :cognitive)
    3.times do |i|
      r = engine.excavate(site_id: site.id)
      engine.all_artifacts.find { |a| a.id == r[:artifact_id] }.preservation = (i + 1) * 0.2
    end
    ps = engine.most_fragile(limit: 3).map(&:preservation)
    expect(ps).to eq(ps.sort)
  end

  describe '#site_report' do
    let(:site) { engine.create_site(domain: :cognitive) }
    before { 2.times { engine.excavate(site_id: site.id) } }
    it 'includes required keys' do expect(engine.site_report(site_id: site.id)).to include(:id, :domain, :current_depth, :artifacts_count) end
    it 'includes artifact_breakdown' do expect(engine.site_report(site_id: site.id)[:artifact_breakdown]).to be_a(Hash) end
    it 'includes depth_progress' do expect(engine.site_report(site_id: site.id)[:depth_progress]).to include(:current_index, :total_levels, :pct_complete) end
    it 'raises for unknown site' do expect { engine.site_report(site_id: 'x') }.to raise_error(ArgumentError) end
  end

  describe '#archaeology_report' do
    let(:s1) { engine.create_site(domain: :cognitive) }
    let(:s2) { engine.create_site(domain: :emotional) }
    before { 3.times { engine.excavate(site_id: s1.id) }; engine.excavate(site_id: s2.id); 5.times { engine.dig(site_id: s2.id) } }

    it 'total_sites=2' do expect(engine.archaeology_report[:total_sites]).to eq(2) end
    it 'total_artifacts=4' do expect(engine.archaeology_report[:total_artifacts]).to eq(4) end
    it 'completed_sites=1' do expect(engine.archaeology_report[:completed_sites]).to eq(1) end
    it 'active_sites=1' do expect(engine.archaeology_report[:active_sites]).to eq(1) end
    it 'by_type has all types' do C::ARTIFACT_TYPES.each { |t| expect(engine.archaeology_report[:by_type]).to have_key(t) } end
    it 'by_domain has all domains' do C::DOMAIN_TYPES.each { |d| expect(engine.archaeology_report[:by_domain]).to have_key(d) } end
    it 'by_depth has all depths' do C::EXCAVATION_DEPTH_LEVELS.each { |d| expect(engine.archaeology_report[:by_depth]).to have_key(d) } end
    it 'avg_preservation is numeric' do expect(engine.archaeology_report[:avg_preservation]).to be_a(Numeric) end
    it 'avg_preservation 0.0 when empty' do expect(described_class.new.archaeology_report[:avg_preservation]).to eq(0.0) end
    it 'counts fragments' do engine.all_artifacts.first(2).each { |a| a.preservation = 0.1 }; expect(engine.archaeology_report[:fragments]).to be >= 2 end
  end
end
