# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::CognitiveArchaeology::Runners::CognitiveArchaeology do
  let(:engine) { Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new }
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  describe '#bury_artifact' do
    it 'returns success with artifact data' do
      result = runner.bury_artifact(content: 'pottery shard', domain: 'craft',
                                    stratum_depth: 3, engine: engine)
      expect(result[:success]).to be true
      expect(result[:content]).to eq('pottery shard')
    end

    it 'returns failure when limit reached' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_ARTIFACTS', 0)
      result = runner.bury_artifact(content: 'x', domain: 'd', stratum_depth: 0, engine: engine)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:limit_or_missing_stratum)
    end
  end

  describe '#excavate' do
    it 'returns artifacts at given depth' do
      runner.bury_artifact(content: 'bone', domain: 'organic', stratum_depth: 4, engine: engine)
      result = runner.excavate(stratum_depth: 4, engine: engine)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end

    it 'returns empty for unexcavated depth' do
      result = runner.excavate(stratum_depth: 99, engine: engine)
      expect(result[:count]).to eq(0)
    end
  end

  describe '#survey' do
    it 'returns artifacts across all strata' do
      runner.bury_artifact(content: 'a', domain: 'd', stratum_depth: 1, engine: engine)
      runner.bury_artifact(content: 'b', domain: 'd', stratum_depth: 8, engine: engine)
      result = runner.survey(engine: engine)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#date_artifact' do
    it 'returns dating info' do
      buried = runner.bury_artifact(content: 'coin', domain: 'metal', stratum_depth: 7, engine: engine)
      result = runner.date_artifact(artifact_id: buried[:id], engine: engine)
      expect(result[:success]).to be true
      expect(result[:stratum_depth]).to eq(7)
    end

    it 'returns failure for missing artifact' do
      result = runner.date_artifact(artifact_id: 'ghost', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#restore_artifact' do
    it 'improves preservation' do
      buried = runner.bury_artifact(content: 'tile', domain: 'arch', stratum_depth: 5,
                                    preservation_quality: 0.5, engine: engine)
      result = runner.restore_artifact(artifact_id: buried[:id], engine: engine)
      expect(result[:success]).to be true
      expect(result[:preservation_quality]).to be > 0.5
    end

    it 'returns failure for missing artifact' do
      result = runner.restore_artifact(artifact_id: 'nope', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#catalog_artifact' do
    it 'catalogs and returns data' do
      buried = runner.bury_artifact(content: 'mask', domain: 'ritual', stratum_depth: 3, engine: engine)
      result = runner.catalog_artifact(artifact_id: buried[:id], engine: engine)
      expect(result[:success]).to be true
      expect(result[:content]).to eq('mask')
    end

    it 'returns failure for missing artifact' do
      result = runner.catalog_artifact(artifact_id: 'phantom', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#cross_reference' do
    it 'finds shared content across strata' do
      runner.bury_artifact(content: 'fire', domain: 'ritual', stratum_depth: 2,
                           artifact_type: :ritual, engine: engine)
      runner.bury_artifact(content: 'fire', domain: 'ritual', stratum_depth: 9,
                           artifact_type: :ritual, engine: engine)
      result = runner.cross_reference(domain: 'ritual', engine: engine)
      expect(result[:success]).to be true
      expect(result[:count]).to be >= 1
    end
  end

  describe '#deepest_artifacts' do
    it 'returns deepest first' do
      runner.bury_artifact(content: 'shallow', domain: 'd', stratum_depth: 1, engine: engine)
      runner.bury_artifact(content: 'deep', domain: 'd', stratum_depth: 15, engine: engine)
      result = runner.deepest_artifacts(engine: engine)
      expect(result[:artifacts].first[:stratum_depth]).to eq(15)
    end
  end

  describe '#surface_finds' do
    it 'returns shallowest stratum artifacts' do
      runner.bury_artifact(content: 'recent', domain: 'd', stratum_depth: 0, engine: engine)
      runner.bury_artifact(content: 'old', domain: 'd', stratum_depth: 12, engine: engine)
      result = runner.surface_finds(engine: engine)
      expect(result[:artifacts].any? { |a| a[:content] == 'recent' }).to be true
    end
  end

  describe '#excavation_report' do
    it 'returns report hash' do
      runner.bury_artifact(content: 'x', domain: 'd', stratum_depth: 3, engine: engine)
      result = runner.excavation_report(engine: engine)
      expect(result[:success]).to be true
      expect(result[:total_artifacts]).to eq(1)
    end
  end
end
