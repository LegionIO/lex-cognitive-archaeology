# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::Constants do
  subject(:mod) { described_class }

  it 'defines MAX_ARTIFACTS as 500' do
    expect(mod::MAX_ARTIFACTS).to eq(500)
  end

  it 'defines MAX_STRATA as 20' do
    expect(mod::MAX_STRATA).to eq(20)
  end

  it 'defines DEFAULT_PRESERVATION as 0.6' do
    expect(mod::DEFAULT_PRESERVATION).to eq(0.6)
  end

  it 'defines PRESERVATION_DECAY as 0.02' do
    expect(mod::PRESERVATION_DECAY).to eq(0.02)
  end

  it 'defines RESTORATION_BOOST as 0.15' do
    expect(mod::RESTORATION_BOOST).to eq(0.15)
  end

  it 'defines SEDIMENT_DENSITY_DEFAULT as 0.5' do
    expect(mod::SEDIMENT_DENSITY_DEFAULT).to eq(0.5)
  end

  it 'defines 5 ARTIFACT_TYPES' do
    expect(mod::ARTIFACT_TYPES.size).to eq(5)
    expect(mod::ARTIFACT_TYPES).to include(:tool, :symbol, :ritual, :structure, :fragment)
  end

  it 'defines 8 EPOCH_NAMES' do
    expect(mod::EPOCH_NAMES.size).to eq(8)
    expect(mod::EPOCH_NAMES).to include(:genesis, :current, :crisis, :maturation)
  end

  it 'defines PRESERVATION_LABELS as a Hash' do
    expect(mod::PRESERVATION_LABELS).to be_a(Hash)
    expect(mod::PRESERVATION_LABELS).not_to be_empty
  end

  it 'defines DEPTH_LABELS as a Hash' do
    expect(mod::DEPTH_LABELS).to be_a(Hash)
  end

  it 'defines DENSITY_LABELS as a Hash' do
    expect(mod::DENSITY_LABELS).to be_a(Hash)
  end

  describe '.label_for' do
    it 'returns :pristine for high preservation' do
      expect(mod.label_for(mod::PRESERVATION_LABELS, 0.95)).to eq(:pristine)
    end

    it 'returns :intact for 0.7' do
      expect(mod.label_for(mod::PRESERVATION_LABELS, 0.7)).to eq(:intact)
    end

    it 'returns :dust for very low preservation' do
      expect(mod.label_for(mod::PRESERVATION_LABELS, 0.1)).to eq(:dust)
    end

    it 'returns :surface for depth 0' do
      expect(mod.label_for(mod::DEPTH_LABELS, 0)).to eq(:surface)
    end

    it 'returns :bedrock for depth 18' do
      expect(mod.label_for(mod::DEPTH_LABELS, 18)).to eq(:bedrock)
    end

    it 'returns :compacted for density 0.9' do
      expect(mod.label_for(mod::DENSITY_LABELS, 0.9)).to eq(:compacted)
    end

    it 'returns last label when no range matches' do
      expect(mod.label_for(mod::PRESERVATION_LABELS, -1.0)).to eq(mod::PRESERVATION_LABELS.values.last)
    end
  end
end
