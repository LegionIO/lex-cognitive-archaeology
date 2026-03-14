# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite do
  let(:mod)    { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }
  let(:domain) { :cognitive }

  def build_site(d = domain)
    described_class.new(domain: d)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(build_site.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets domain as symbol' do
      expect(build_site(:semantic).domain).to eq(:semantic)
    end

    it 'starts at surface depth' do
      expect(build_site.current_depth).to eq(:surface)
    end

    it 'initializes artifacts_found as empty array' do
      expect(build_site.artifacts_found).to eq([])
    end

    it 'assigns started_at as UTC Time' do
      expect(build_site.started_at).to be_a(Time)
    end

    it 'raises ArgumentError for invalid domain' do
      expect { build_site(:nope) }.to raise_error(ArgumentError, /unknown domain/)
    end

    mod::DOMAIN_TYPES.each do |d|
      it "accepts domain :#{d}" do
        expect { build_site(d) }.not_to raise_error
      end
    end
  end

  describe '#dig_deeper!' do
    it 'advances the depth level' do
      site = build_site
      site.dig_deeper!
      expect(site.current_depth).to eq(:shallow)
    end

    it 'returns true when dug' do
      expect(build_site.dig_deeper!).to be true
    end

    it 'returns false when already at bedrock' do
      site = build_site
      4.times { site.dig_deeper! }
      expect(site.dig_deeper!).to be false
    end

    it 'does not advance past bedrock' do
      site = build_site
      5.times { site.dig_deeper! }
      expect(site.current_depth).to eq(:bedrock)
    end

    it 'progresses through all depth levels' do
      site   = build_site
      levels = [site.current_depth]
      levels << site.current_depth while site.dig_deeper!
      expect(levels).to eq(mod::EXCAVATION_DEPTH_LEVELS)
    end
  end

  describe '#complete?' do
    it 'returns false at surface' do
      expect(build_site.complete?).to be false
    end

    it 'returns true at bedrock' do
      site = build_site
      4.times { site.dig_deeper! }
      expect(site.complete?).to be true
    end
  end

  describe '#excavate!' do
    it 'returns an Artifact' do
      site = build_site
      expect(site.excavate!).to be_a(Legion::Extensions::CognitiveArchaeology::Helpers::Artifact)
    end

    it 'adds the artifact to artifacts_found' do
      site = build_site
      artifact = site.excavate!
      expect(site.artifacts_found).to include(artifact)
    end

    it 'artifact has matching domain' do
      site     = build_site(:emotional)
      artifact = site.excavate!
      expect(artifact.domain).to eq(:emotional)
    end

    it 'artifact has matching depth_level' do
      site     = build_site
      artifact = site.excavate!
      expect(artifact.depth_level).to eq(:surface)
    end

    it 'artifact type is from ARTIFACT_TYPES' do
      site = build_site
      expect(mod::ARTIFACT_TYPES).to include(site.excavate!.type)
    end

    it 'trims artifacts_found to MAX_ARTIFACTS' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_ARTIFACTS', 3)
      site = build_site
      5.times { site.excavate! }
      expect(site.artifacts_found.size).to eq(3)
    end
  end

  describe '#survey' do
    subject(:s) { build_site.survey }

    it 'includes :id' do
      expect(s).to have_key(:id)
    end

    it 'includes :domain' do
      expect(s[:domain]).to eq(domain)
    end

    it 'includes :current_depth' do
      expect(s[:current_depth]).to eq(:surface)
    end

    it 'includes :depth_label string' do
      expect(s[:depth_label]).to be_a(String)
    end

    it 'includes :artifacts_count of 0 initially' do
      expect(s[:artifacts_count]).to eq(0)
    end

    it 'includes :complete as false' do
      expect(s[:complete]).to be false
    end

    it 'includes :started_at' do
      expect(s).to have_key(:started_at)
    end
  end

  describe '#to_h' do
    it 'includes survey keys plus :artifacts array' do
      site = build_site
      h    = site.to_h
      expect(h).to have_key(:artifacts)
      expect(h[:artifacts]).to eq([])
    end

    it 'includes artifact hashes after excavating' do
      site = build_site
      site.excavate!
      expect(site.to_h[:artifacts].size).to eq(1)
    end
  end
end
