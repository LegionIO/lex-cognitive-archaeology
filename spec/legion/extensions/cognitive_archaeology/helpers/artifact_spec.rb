# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::Artifact do
  let(:mod) { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }
  let(:valid_type)   { :pattern }
  let(:valid_domain) { :cognitive }
  let(:valid_depth)  { :surface }

  def build(**overrides)
    described_class.new(
      type:        valid_type,
      domain:      valid_domain,
      content:     'test content',
      depth_level: valid_depth,
      **overrides
    )
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(build.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'symbolizes type' do
      expect(build(type: 'skill').type).to eq(:skill)
    end

    it 'symbolizes domain' do
      expect(build(domain: 'emotional').domain).to eq(:emotional)
    end

    it 'symbolizes depth_level' do
      expect(build(depth_level: 'mid').depth_level).to eq(:mid)
    end

    it 'defaults preservation to DEFAULT_PRESERVATION' do
      expect(build.preservation).to eq(mod::DEFAULT_PRESERVATION)
    end

    it 'clamps preservation to 0..1' do
      expect(build(preservation: 2.5).preservation).to eq(1.0)
      expect(build(preservation: -1.0).preservation).to eq(0.0)
    end

    it 'assigns discovered_at as UTC Time' do
      expect(build.discovered_at).to be_a(Time)
    end

    it 'assigns origin_epoch when not provided' do
      expect(build.origin_epoch).to be_a(Time)
    end

    it 'accepts explicit origin_epoch' do
      epoch = Time.now.utc - 1_000_000
      expect(build(origin_epoch: epoch).origin_epoch).to eq(epoch)
    end

    it 'initializes contextual_links as empty array by default' do
      expect(build.contextual_links).to eq([])
    end

    it 'accepts contextual_links array' do
      links = %w[id1 id2]
      expect(build(contextual_links: links).contextual_links).to eq(links)
    end

    it 'raises ArgumentError for invalid type' do
      expect { build(type: :unknown_type) }.to raise_error(ArgumentError, /unknown artifact type/)
    end

    it 'raises ArgumentError for invalid domain' do
      expect { build(domain: :nonexistent) }.to raise_error(ArgumentError, /unknown domain/)
    end

    it 'raises ArgumentError for invalid depth_level' do
      expect { build(depth_level: :abyss) }.to raise_error(ArgumentError, /unknown depth level/)
    end

    mod::ARTIFACT_TYPES.each do |t|
      it "accepts artifact type :#{t}" do
        expect { build(type: t) }.not_to raise_error
      end
    end

    mod::DOMAIN_TYPES.each do |d|
      it "accepts domain :#{d}" do
        expect { build(domain: d) }.not_to raise_error
      end
    end

    mod::EXCAVATION_DEPTH_LEVELS.each do |level|
      it "accepts depth_level :#{level}" do
        expect { build(depth_level: level) }.not_to raise_error
      end
    end
  end

  describe '#decay!' do
    it 'decreases preservation by PRESERVATION_DECAY' do
      artifact = build(preservation: 0.8)
      original = artifact.preservation
      artifact.decay!
      expect(artifact.preservation).to be < original
      expect(artifact.preservation).to be_within(0.001).of(original - mod::PRESERVATION_DECAY)
    end

    it 'clamps preservation to 0.0 minimum' do
      artifact = build(preservation: 0.01)
      artifact.decay!(rate: 0.5)
      expect(artifact.preservation).to eq(0.0)
    end

    it 'also decreases integrity' do
      artifact = build(preservation: 0.8)
      original = artifact.integrity
      artifact.decay!
      expect(artifact.integrity).to be <= original
    end

    it 'rounds to 10 decimal places' do
      artifact = build(preservation: 0.123456789)
      artifact.decay!
      expect(artifact.preservation.to_s.length).to be <= 12
    end

    it 'returns self for chaining' do
      artifact = build
      expect(artifact.decay!).to be(artifact)
    end
  end

  describe '#restore!' do
    it 'increases preservation by boost' do
      artifact = build(preservation: 0.4)
      artifact.restore!(boost: 0.2)
      expect(artifact.preservation).to be_within(0.001).of(0.6)
    end

    it 'clamps preservation to 1.0 maximum' do
      artifact = build(preservation: 0.95)
      artifact.restore!(boost: 0.5)
      expect(artifact.preservation).to eq(1.0)
    end

    it 'also increases integrity' do
      artifact = build(preservation: 0.4)
      original = artifact.integrity
      artifact.restore!
      expect(artifact.integrity).to be >= original
    end

    it 'returns self for chaining' do
      artifact = build
      expect(artifact.restore!).to be(artifact)
    end
  end

  describe '#fragment?' do
    it 'returns true when preservation < 0.3' do
      expect(build(preservation: 0.2).fragment?).to be true
    end

    it 'returns false when preservation >= 0.3' do
      expect(build(preservation: 0.5).fragment?).to be false
    end
  end

  describe '#well_preserved?' do
    it 'returns true when preservation > 0.7' do
      expect(build(preservation: 0.8).well_preserved?).to be true
    end

    it 'returns false when preservation <= 0.7' do
      expect(build(preservation: 0.5).well_preserved?).to be false
    end
  end

  describe '#ancient?' do
    it 'returns true when origin_epoch is more than 180 days ago' do
      old = Time.now.utc - 16_000_000
      expect(build(origin_epoch: old).ancient?).to be true
    end

    it 'returns false for recent origin_epoch' do
      recent = Time.now.utc - 1000
      expect(build(origin_epoch: recent).ancient?).to be false
    end
  end

  describe '#preservation_label' do
    it 'returns :dust for low preservation' do
      expect(build(preservation: 0.1).preservation_label).to eq(:dust)
    end

    it 'returns :pristine for high preservation' do
      expect(build(preservation: 0.9).preservation_label).to eq(:pristine)
    end

    it 'returns :partial for mid-range preservation' do
      expect(build(preservation: 0.5).preservation_label).to eq(:partial)
    end
  end

  describe '#integrity_label' do
    it 'returns :corrupted for low integrity' do
      artifact = build
      artifact.integrity = 0.1
      expect(artifact.integrity_label).to eq(:corrupted)
    end

    it 'returns :complete for high integrity' do
      artifact = build
      artifact.integrity = 0.9
      expect(artifact.integrity_label).to eq(:complete)
    end
  end

  describe '#link_to' do
    it 'adds other_id to contextual_links' do
      artifact = build
      artifact.link_to('some-uuid')
      expect(artifact.contextual_links).to include('some-uuid')
    end

    it 'does not duplicate links' do
      artifact = build
      artifact.link_to('some-uuid')
      artifact.link_to('some-uuid')
      expect(artifact.contextual_links.count('some-uuid')).to eq(1)
    end
  end

  describe '#to_h' do
    subject(:hash) { build.to_h }

    %i[id type domain content depth_level preservation preservation_label
       integrity integrity_label discovered_at origin_epoch contextual_links
       fragment well_preserved ancient].each do |key|
      it "includes :#{key}" do
        expect(hash).to have_key(key)
      end
    end
  end
end
