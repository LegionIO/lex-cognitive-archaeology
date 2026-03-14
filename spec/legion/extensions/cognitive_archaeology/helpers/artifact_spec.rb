# frozen_string_literal: true
RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::Artifact do
  let(:va) { { type: :pattern, domain: :cognitive, content: 'x', depth_level: :surface } }
  subject(:a) { described_class.new(**va) }
  let(:C) { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }

  it 'assigns a uuid id' do expect(a.id).to match(/\A[0-9a-f-]{36}\z/) end
  it 'assigns type' do expect(a.type).to eq(:pattern) end
  it 'assigns domain' do expect(a.domain).to eq(:cognitive) end
  it 'assigns content' do expect(a.content).to eq('x') end
  it 'assigns depth_level' do expect(a.depth_level).to eq(:surface) end
  it 'defaults preservation to DEFAULT_PRESERVATION' do expect(a.preservation).to eq(C::DEFAULT_PRESERVATION) end
  it 'clamps preservation above 1.0' do expect(described_class.new(**va, preservation: 2.0).preservation).to eq(1.0) end
  it 'assigns integrity 0..1' do expect(a.integrity).to be_between(0.0, 1.0) end
  it 'assigns discovered_at as Time' do expect(a.discovered_at).to be_a(Time) end
  it 'assigns origin_epoch as Time' do expect(a.origin_epoch).to be_a(Time) end
  it 'accepts explicit origin_epoch' do
    e = Time.now.utc - 100; expect(described_class.new(**va, origin_epoch: e).origin_epoch).to eq(e)
  end
  it 'starts with empty contextual_links' do expect(a.contextual_links).to eq([]) end
  it 'accepts contextual_links' do expect(described_class.new(**va, contextual_links: %w[x]).contextual_links).to eq(['x']) end
  it 'raises on invalid type' do expect { described_class.new(**va, type: :nope) }.to raise_error(ArgumentError, /unknown artifact type/) end
  it 'raises on invalid domain' do expect { described_class.new(**va, domain: :nope) }.to raise_error(ArgumentError, /unknown domain/) end
  it 'raises on invalid depth_level' do expect { described_class.new(**va, depth_level: :nope) }.to raise_error(ArgumentError, /unknown depth level/) end
  it 'coerces string type to symbol' do expect(described_class.new(**va, type: 'skill').type).to eq(:skill) end
  it 'coerces string domain to symbol' do expect(described_class.new(**va, domain: 'emotional').domain).to eq(:emotional) end

  describe '#decay!' do
    it 'reduces preservation' do orig = a.preservation; a.decay!; expect(a.preservation).to be < orig end
    it 'reduces by custom rate' do a.decay!(rate: 0.1); expect(a.preservation).to be_within(0.001).of(C::DEFAULT_PRESERVATION - 0.1) end
    it 'clamps at 0.0' do a.preservation = 0.01; a.decay!(rate: 0.5); expect(a.preservation).to eq(0.0) end
    it 'decays integrity at half rate' do orig = a.integrity; a.decay!(rate: 0.1); expect(a.integrity).to be < orig end
    it 'returns self' do expect(a.decay!).to eq(a) end
  end

  describe '#restore!' do
    it 'increases preservation' do a.preservation = 0.3; a.restore!; expect(a.preservation).to be > 0.3 end
    it 'uses custom boost' do a.preservation = 0.4; a.restore!(boost: 0.2); expect(a.preservation).to be_within(0.001).of(0.6) end
    it 'clamps at 1.0' do a.preservation = 0.95; a.restore!(boost: 0.5); expect(a.preservation).to eq(1.0) end
    it 'restores integrity' do a.integrity = 0.5; a.restore!(boost: 0.2); expect(a.integrity).to be > 0.5 end
    it 'returns self' do expect(a.restore!).to eq(a) end
  end

  it 'fragment? true when < 0.3' do a.preservation = 0.2; expect(a.fragment?).to be true end
  it 'fragment? false when >= 0.3' do a.preservation = 0.5; expect(a.fragment?).to be false end
  it 'well_preserved? true when > 0.7' do a.preservation = 0.8; expect(a.well_preserved?).to be true end
  it 'well_preserved? false when <= 0.7' do a.preservation = 0.5; expect(a.well_preserved?).to be false end
  it 'ancient? true for old origin_epoch' do
    expect(described_class.new(**va, origin_epoch: Time.now.utc - (181 * 86_400)).ancient?).to be true
  end
  it 'ancient? false for recent origin_epoch' do
    expect(described_class.new(**va, origin_epoch: Time.now.utc - 100).ancient?).to be false
  end

  describe '#preservation_label' do
    { 0.1 => :dust, 0.3 => :fragmented, 0.5 => :partial, 0.7 => :intact, 0.9 => :pristine }.each do |v, label|
      it "#{v} => #{label}" do a.preservation = v; expect(a.preservation_label).to eq(label) end
    end
  end

  describe '#integrity_label' do
    { 0.1 => :corrupted, 0.7 => :coherent, 0.9 => :complete }.each do |v, label|
      it "#{v} => #{label}" do a.integrity = v; expect(a.integrity_label).to eq(label) end
    end
  end

  it '#link_to adds link' do a.link_to('x'); expect(a.contextual_links).to include('x') end
  it '#link_to no dup' do a.link_to('x'); a.link_to('x'); expect(a.contextual_links.count('x')).to eq(1) end

  describe '#to_h' do
    it 'includes all keys' do
      %i[id type domain content depth_level preservation preservation_label integrity integrity_label
         discovered_at origin_epoch contextual_links fragment well_preserved ancient].each do |k|
        expect(a.to_h).to have_key(k)
      end
    end
    it ':fragment reflects state' do a.preservation = 0.1; expect(a.to_h[:fragment]).to be true end
    it ':well_preserved reflects state' do a.preservation = 0.9; expect(a.to_h[:well_preserved]).to be true end
  end

  describe 'all types accepted' do
    C::ARTIFACT_TYPES.each do |t|
      it "accepts :#{t}" do expect { described_class.new(**va, type: t) }.not_to raise_error end
    end
  end
  describe 'all domains accepted' do
    C::DOMAIN_TYPES.each do |d|
      it "accepts :#{d}" do expect { described_class.new(**va, domain: d) }.not_to raise_error end
    end
  end
  describe 'all depth levels accepted' do
    C::EXCAVATION_DEPTH_LEVELS.each do |d|
      it "accepts :#{d}" do expect { described_class.new(**va, depth_level: d) }.not_to raise_error end
    end
  end
end
