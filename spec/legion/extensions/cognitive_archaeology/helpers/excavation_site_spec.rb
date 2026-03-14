# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ExcavationSite do
  let(:constants) { Legion::Extensions::CognitiveArchaeology::Helpers::Constants }
  let(:site) { described_class.new(domain: :cognitive) }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(site.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets domain' do
      expect(site.domain).to eq :cognitive
    end

    it 'starts at surface depth' do
      expect(site.current_depth).to eq :surface
    end

    it 'starts with no artifacts' do
      expect(site.artifacts_found).to be_empty
    end

    it 'sets started_at' do
      expect(site.started_at).to be_a Time
    end

    it 'raises on invalid domain' do
      expect do
        described_class.new(domain: :bogus)
      end.to raise_error(ArgumentError, /unknown domain/)
    end
  end

  describe '#dig_deeper!' do
    it 'advances depth from surface to shallow' do
      site.dig_deeper!
      expect(site.current_depth).to eq :shallow
    end

    it 'advances through all levels' do
      levels = constants::EXCAVATION_DEPTH_LEVELS
      (levels.size - 1).times { site.dig_deeper! }
      expect(site.current_depth).to eq :bedrock
    end

    it 'returns true when advancing' do
      expect(site.dig_deeper!).to be true
    end

    it 'returns false at bedrock' do
      4.times { site.dig_deeper! }
      expect(site.dig_deeper!).to be false
    end
  end

  describe '#excavate!' do
    it 'returns an Artifact' do
      artifact = site.excavate!
      expect(artifact).to be_a(
        Legion::Extensions::CognitiveArchaeology::Helpers::Artifact
      )
    end

    it 'adds artifact to artifacts_found' do
      site.excavate!
      expect(site.artifacts_found.size).to eq 1
    end

    it 'creates artifact at current depth' do
      site.dig_deeper!
      artifact = site.excavate!
      expect(artifact.depth_level).to eq :shallow
    end

    it 'creates artifact in site domain' do
      artifact = site.excavate!
      expect(artifact.domain).to eq :cognitive
    end

    it 'creates artifact with valid type' do
      artifact = site.excavate!
      expect(constants::ARTIFACT_TYPES).to include(artifact.artifact_type)
    end
  end

  describe '#survey' do
    subject(:survey) { site.survey }

    it 'returns a hash with expected keys' do
      %i[id domain current_depth depth_label artifacts_count
         complete started_at].each do |key|
        expect(survey).to have_key(key)
      end
    end

    it 'returns correct domain' do
      expect(survey[:domain]).to eq :cognitive
    end

    it 'returns correct artifact count' do
      site.excavate!
      expect(site.survey[:artifacts_count]).to eq 1
    end
  end

  describe '#complete?' do
    it 'returns false initially' do
      expect(site.complete?).to be false
    end

    it 'returns true at bedrock' do
      4.times { site.dig_deeper! }
      expect(site.complete?).to be true
    end
  end

  describe '#to_h' do
    it 'includes survey data and artifacts array' do
      site.excavate!
      h = site.to_h
      expect(h).to have_key(:artifacts)
      expect(h[:artifacts]).to be_an Array
      expect(h[:artifacts].first).to have_key(:id)
    end
  end
end
