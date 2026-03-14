# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::Stratum do
  subject(:stratum) { described_class.new(depth: 5, epoch_name: :formation) }

  describe '#initialize' do
    it 'stores depth as integer' do
      expect(stratum.depth).to eq(5)
    end

    it 'stores epoch_name as symbol' do
      expect(stratum.epoch_name).to eq(:formation)
    end

    it 'defaults sediment_density to SEDIMENT_DENSITY_DEFAULT' do
      expect(stratum.sediment_density).to eq(0.5)
    end

    it 'starts with empty artifacts' do
      expect(stratum.artifacts).to be_empty
    end

    it 'clamps sediment_density to [0,1]' do
      s = described_class.new(depth: 0, sediment_density: 1.5)
      expect(s.sediment_density).to eq(1.0)
    end
  end

  describe '#add_artifact' do
    let(:artifact) do
      Legion::Extensions::CognitiveArchaeology::Helpers::Artifact.new(
        content: 'shard', domain: :craft, stratum_depth: 5
      )
    end

    it 'adds an artifact and returns it' do
      result = stratum.add_artifact(artifact)
      expect(result).to eq(artifact)
      expect(stratum.artifacts).to include(artifact)
    end
  end

  describe '#remove_artifact' do
    let(:artifact) do
      Legion::Extensions::CognitiveArchaeology::Helpers::Artifact.new(
        content: 'shard', domain: :craft, stratum_depth: 5
      )
    end

    it 'removes an artifact by id' do
      stratum.add_artifact(artifact)
      stratum.remove_artifact(artifact.id)
      expect(stratum.artifacts).to be_empty
    end
  end

  describe '#find_artifact' do
    let(:artifact) do
      Legion::Extensions::CognitiveArchaeology::Helpers::Artifact.new(
        content: 'relic', domain: :ritual, stratum_depth: 5
      )
    end

    it 'finds by id' do
      stratum.add_artifact(artifact)
      expect(stratum.find_artifact(artifact.id)).to eq(artifact)
    end

    it 'returns nil for missing id' do
      expect(stratum.find_artifact('missing')).to be_nil
    end
  end

  describe '#artifacts_by_type' do
    it 'filters by artifact_type' do
      a1 = Legion::Extensions::CognitiveArchaeology::Helpers::Artifact.new(
        content: 'x', domain: :craft, stratum_depth: 5, artifact_type: :tool
      )
      a2 = Legion::Extensions::CognitiveArchaeology::Helpers::Artifact.new(
        content: 'y', domain: :craft, stratum_depth: 5, artifact_type: :symbol
      )
      stratum.add_artifact(a1)
      stratum.add_artifact(a2)
      expect(stratum.artifacts_by_type(:tool).size).to eq(1)
    end
  end

  describe '#density_label' do
    it 'returns a symbol label' do
      expect(stratum.density_label).to be_a(Symbol)
    end
  end

  describe '#depth_label' do
    it 'returns :shallow for depth 5' do
      expect(stratum.depth_label).to eq(:shallow)
    end
  end

  describe '#to_h' do
    it 'includes expected keys' do
      h = stratum.to_h
      expect(h).to include(:depth, :epoch_name, :sediment_density,
                            :density_label, :depth_label, :artifact_count)
    end

    it 'has artifact_count of 0 initially' do
      expect(stratum.to_h[:artifact_count]).to eq(0)
    end
  end
end
