# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine do
  subject(:engine) { described_class.new }

  def create_and_excavate(domain: :cognitive)
    site = engine.create_site(domain: domain)
    engine.excavate(site_id: site.id)
  end

  describe '#create_site' do
    it('creates') { expect(engine.create_site(domain: :cognitive).domain).to eq(:cognitive) }
    it('stores') { s = engine.create_site(domain: :cognitive); expect(engine.all_sites).to include(s) }
  end
  describe '#dig' do
    it('advances') do
      s = engine.create_site(domain: :cognitive)
      r = engine.dig(site_id: s.id)
      expect(r[:dug]).to be true
    end
    it('raises unknown') { expect { engine.dig(site_id: 'bad') }.to raise_error(ArgumentError) }
  end
  describe '#excavate' do
    it('returns artifact') { a = create_and_excavate; expect(a.type).to be_a(Symbol) }
    it('stores') { a = create_and_excavate; expect(engine.all_artifacts).to include(a) }
  end
  describe '#restore_artifact' do
    it('boosts') { a = create_and_excavate; p0 = a.preservation; engine.restore_artifact(artifact_id: a.id); expect(a.preservation).to be > p0 }
    it('raises unknown') { expect { engine.restore_artifact(artifact_id: 'bad') }.to raise_error(ArgumentError) }
  end
  describe '#decay_all!' do
    it('decays') { a = create_and_excavate; p0 = a.preservation; engine.decay_all!; expect(a.preservation).to be < p0 }
    it('prunes') { a = create_and_excavate; a.preservation = 0.01; engine.decay_all!(rate: 0.1); expect(engine.all_artifacts).not_to include(a) }
  end
  it('by_type') { a = create_and_excavate; expect(engine.artifacts_by_type(a.type)).to include(a) }
  it('by_domain') { create_and_excavate(domain: :cognitive); expect(engine.artifacts_by_domain(:cognitive)).not_to be_empty }
  it('by_depth') { create_and_excavate; expect(engine.artifacts_by_depth(:surface)).not_to be_empty }
  it('best_preserved') { 3.times { create_and_excavate }; expect(engine.best_preserved(limit: 2).size).to be <= 2 }
  it('most_fragile') { a = create_and_excavate; a.preservation = 0.1; expect(engine.most_fragile).to include(a) }
  it('site_report') { s = engine.create_site(domain: :cognitive); expect(engine.site_report(site_id: s.id)).to include(:id, :domain) }
  describe '#archaeology_report' do
    it('keys') { create_and_excavate; expect(engine.archaeology_report).to include(:total_artifacts, :avg_preservation) }
    it('zeros') { expect(engine.archaeology_report[:total_artifacts]).to eq(0) }
  end
end
