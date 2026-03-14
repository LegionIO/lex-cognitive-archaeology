# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite do
  subject(:site) { described_class.new(domain: :cognitive) }
  it('uuid') { expect(site.id).to match(/\A[0-9a-f-]{36}\z/) }
  it('domain') { expect(site.domain).to eq(:cognitive) }
  it('starts surface') { expect(site.current_depth).to eq(:surface) }
  it('empty artifacts') { expect(site.artifacts_found).to be_empty }
  describe '#dig_deeper!' do
    it('advances') { site.dig_deeper!; expect(site.current_depth).to eq(:shallow) }
    it('all levels') { 4.times { site.dig_deeper! }; expect(site.current_depth).to eq(:bedrock) }
    it('false at bedrock') { 4.times { site.dig_deeper! }; expect(site.dig_deeper!).to be false }
  end
  describe '#excavate!' do
    it('returns artifact') { expect(site.excavate!).to be_a(Legion::Extensions::CognitiveArchaeology::Helpers::Artifact) }
    it('records') { site.excavate!; expect(site.artifacts_found.size).to eq(1) }
    it('matches domain') { expect(site.excavate!.domain).to eq(:cognitive) }
    it('matches depth') { site.dig_deeper!; expect(site.excavate!.depth_level).to eq(:shallow) }
  end
  it('survey keys') { expect(site.survey).to include(:id, :domain, :current_depth, :artifacts_count) }
  it('to_h artifacts') { site.excavate!; expect(site.to_h[:artifacts].size).to eq(1) }
end
