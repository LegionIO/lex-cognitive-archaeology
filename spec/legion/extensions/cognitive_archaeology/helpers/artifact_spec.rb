# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::Artifact do
  subject(:art) { described_class.new(type: :pattern, domain: :cognitive, content: 'habit', depth_level: :shallow) }
  it('uuid') { expect(art.id).to match(/\A[0-9a-f-]{36}\z/) }
  it('type') { expect(art.type).to eq(:pattern) }
  it('domain') { expect(art.domain).to eq(:cognitive) }
  it('depth') { expect(art.depth_level).to eq(:shallow) }
  it('default preservation') { expect(art.preservation).to eq(0.5) }
  it('clamps high') { expect(described_class.new(type: :pattern, domain: :cognitive, content: 'x', depth_level: :surface, preservation: 2.0).preservation).to eq(1.0) }
  it('integrity from depth') do
    s = described_class.new(type: :pattern, domain: :cognitive, content: 'x', depth_level: :surface)
    d = described_class.new(type: :pattern, domain: :cognitive, content: 'x', depth_level: :deep)
    expect(s.integrity).to be > d.integrity
  end
  describe '#decay!' do
    it('decreases') { p0 = art.preservation; art.decay!; expect(art.preservation).to be < p0 }
    it('clamps 0') { 50.times { art.decay!(rate: 0.1) }; expect(art.preservation).to eq(0.0) }
  end
  describe '#restore!' do
    it('increases') { art.decay!(rate: 0.3); p0 = art.preservation; art.restore!; expect(art.preservation).to be > p0 }
    it('clamps 1') { 10.times { art.restore!(boost: 0.2) }; expect(art.preservation).to eq(1.0) }
  end
  it('fragment?') { art.preservation = 0.1; expect(art).to be_fragment }
  it('well_preserved?') { art.preservation = 0.9; expect(art).to be_well_preserved }
  it('label') { expect(art.preservation_label).to be_a(Symbol) }
  it('link_to') { art.link_to('x'); art.link_to('x'); expect(art.contextual_links.size).to eq(1) }
  it('to_h keys') { expect(art.to_h).to include(:id, :type, :domain, :preservation, :integrity) }
end
