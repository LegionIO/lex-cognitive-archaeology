# frozen_string_literal: true
RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite do
  subject(:site) { described_class.new(domain: :cognitive) }
  let(:C) { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }

  it 'assigns a uuid id' do expect(site.id).to match(/\A[0-9a-f-]{36}\z/) end
  it 'assigns domain' do expect(site.domain).to eq(:cognitive) end
  it 'starts at surface depth' do expect(site.current_depth).to eq(:surface) end
  it 'starts with no artifacts' do expect(site.artifacts_found).to be_empty end
  it 'records started_at as Time' do expect(site.started_at).to be_a(Time) end
  it 'accepts string domain' do expect(described_class.new(domain: 'emotional').domain).to eq(:emotional) end
  it 'raises on invalid domain' do expect { described_class.new(domain: :nope) }.to raise_error(ArgumentError) end

  describe '#dig_deeper!' do
    it 'advances from surface to shallow' do site.dig_deeper!; expect(site.current_depth).to eq(:shallow) end
    it 'advances through all levels' do C::EXCAVATION_DEPTH_LEVELS.size.times { site.dig_deeper! }; expect(site.current_depth).to eq(C::EXCAVATION_DEPTH_LEVELS.last) end
    it 'returns true when advancing' do expect(site.dig_deeper!).to be true end
    it 'returns false at bedrock' do 5.times { site.dig_deeper! }; expect(site.dig_deeper!).to be false end
    it 'does not pass bedrock' do 6.times { site.dig_deeper! }; expect(site.current_depth).to eq(:bedrock) end
  end

  it 'complete? false before bedrock' do expect(site.complete?).to be false end
  it 'complete? true at bedrock' do 5.times { site.dig_deeper! }; expect(site.complete?).to be true end

  describe '#excavate!' do
    it 'returns an Artifact' do expect(site.excavate!).to be_a(Legion::Extensions::CognitiveArchaeology::Helpers::Artifact) end
    it 'adds to artifacts_found' do site.excavate!; expect(site.artifacts_found.size).to eq(1) end
    it 'artifact domain matches site' do expect(site.excavate!.domain).to eq(:cognitive) end
    it 'artifact depth_level matches current_depth' do expect(site.excavate!.depth_level).to eq(:surface) end
    it 'bedrock yields lower preservation on average' do
      samples = 20.times.map { s = described_class.new(domain: :cognitive); 4.times { s.dig_deeper! }; s.excavate!.preservation }
      expect(samples.sum / samples.size.to_f).to be < 0.4
    end
    it 'accumulates artifacts' do 3.times { site.excavate! }; expect(site.artifacts_found.size).to eq(3) end
    it 'type is valid' do expect(C::ARTIFACT_TYPES).to include(site.excavate!.type) end
  end

  it 'survey includes required keys' do expect(site.survey).to include(:id, :domain, :current_depth, :depth_label, :artifacts_count, :complete, :started_at) end
  it 'survey artifacts_count accurate' do 2.times { site.excavate! }; expect(site.survey[:artifacts_count]).to eq(2) end
  it 'to_h includes artifacts array' do site.excavate!; expect(site.to_h[:artifacts]).to be_an(Array).and have_attributes(size: 1) end
  it 'to_h artifacts are hashes' do site.excavate!; expect(site.to_h[:artifacts].first).to be_a(Hash) end

  describe 'all domains' do
    C::DOMAIN_TYPES.each do |domain|
      it "domain :#{domain}" do s = described_class.new(domain: domain); expect(s.excavate!.domain).to eq(domain) end
    end
  end

  it 'digs surface->shallow->mid->deep->bedrock' do
    %i[shallow mid deep bedrock].each { |d| site.dig_deeper!; expect(site.current_depth).to eq(d) }
  end
end
