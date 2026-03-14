# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine do
  subject(:engine) { described_class.new }

  def bury_one(content: 'test artifact', domain: 'craft', depth: 3, type: :tool, pq: 0.7)
    engine.bury(content: content, domain: domain, stratum_depth: depth,
                artifact_type: type, preservation_quality: pq)
  end

  describe '#stratum_at' do
    it 'creates a stratum at the given depth' do
      s = engine.stratum_at(5)
      expect(s).not_to be_nil
      expect(s.depth).to eq(5)
    end

    it 'returns existing stratum on second call' do
      s1 = engine.stratum_at(2)
      s2 = engine.stratum_at(2)
      expect(s1).to eq(s2)
    end

    it 'assigns an epoch name' do
      s = engine.stratum_at(0)
      expect(s.epoch_name).to be_a(Symbol)
    end

    it 'returns nil when MAX_STRATA is reached' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_STRATA', 1)
      engine.stratum_at(0)
      expect(engine.stratum_at(1)).to be_nil
    end
  end

  describe '#bury' do
    it 'returns an artifact' do
      a = bury_one
      expect(a).not_to be_nil
      expect(a.content).to eq('test artifact')
    end

    it 'creates the stratum if needed' do
      bury_one(depth: 7)
      expect(engine.strata.map(&:depth)).to include(7)
    end

    it 'returns nil when MAX_ARTIFACTS is reached' do
      stub_const('Legion::Extensions::CognitiveArchaeology::Helpers::Constants::MAX_ARTIFACTS', 1)
      bury_one(content: 'a')
      expect(bury_one(content: 'b')).to be_nil
    end
  end

  describe '#excavate' do
    it 'returns artifacts in the stratum' do
      a = bury_one(depth: 4)
      results = engine.excavate(stratum_depth: 4)
      expect(results.map { |r| r[:id] }).to include(a.id)
    end

    it 'filters by domain' do
      bury_one(depth: 4, domain: 'craft')
      bury_one(depth: 4, domain: 'nature', content: 'leaf')
      results = engine.excavate(stratum_depth: 4, domain: 'nature')
      expect(results.all? { |r| r[:domain] == 'nature' }).to be true
    end

    it 'filters by artifact_type' do
      bury_one(depth: 4, type: :symbol, content: 'glyph')
      bury_one(depth: 4, type: :ritual, content: 'rite')
      results = engine.excavate(stratum_depth: 4, artifact_type: :symbol)
      expect(results.all? { |r| r[:artifact_type] == :symbol }).to be true
    end

    it 'filters by min_preservation' do
      bury_one(depth: 4, pq: 0.3)
      bury_one(depth: 4, pq: 0.8, content: 'well preserved')
      results = engine.excavate(stratum_depth: 4, min_preservation: 0.5)
      expect(results.all? { |r| r[:preservation_quality] >= 0.5 }).to be true
    end

    it 'returns empty for unknown stratum' do
      expect(engine.excavate(stratum_depth: 99)).to eq([])
    end
  end

  describe '#survey' do
    it 'returns artifacts across all strata' do
      bury_one(depth: 2)
      bury_one(depth: 6, content: 'deeper')
      expect(engine.survey.size).to eq(2)
    end

    it 'filters by domain across strata' do
      bury_one(depth: 2, domain: 'craft')
      bury_one(depth: 5, domain: 'nature', content: 'pollen')
      results = engine.survey(domain: 'craft')
      expect(results.size).to eq(1)
    end

    it 'includes epoch_name in each result' do
      bury_one
      expect(engine.survey.first).to have_key(:epoch_name)
    end
  end

  describe '#date_artifact' do
    it 'returns dating info for known artifact' do
      a = bury_one(depth: 10)
      result = engine.date_artifact(a.id)
      expect(result[:stratum_depth]).to eq(10)
      expect(result[:artifact_id]).to eq(a.id)
    end

    it 'returns nil for unknown artifact' do
      expect(engine.date_artifact('nope')).to be_nil
    end
  end

  describe '#restore' do
    it 'improves preservation quality' do
      a = bury_one(pq: 0.5)
      before_q = a.preservation_quality
      result = engine.restore(a.id)
      expect(result[:preservation_quality]).to be > before_q
    end

    it 'returns nil for unknown artifact' do
      expect(engine.restore('missing')).to be_nil
    end
  end

  describe '#catalog_artifact' do
    it 'registers artifact in catalog' do
      a = bury_one
      engine.catalog_artifact(a.id)
      expect(engine.catalog).to have_key(a.id)
    end

    it 'returns nil for unknown artifact' do
      expect(engine.catalog_artifact('ghost')).to be_nil
    end
  end

  describe '#cross_reference' do
    it 'finds artifacts with same content in multiple strata' do
      engine.bury(content: 'fire', domain: 'ritual', stratum_depth: 2, artifact_type: :ritual)
      engine.bury(content: 'fire', domain: 'ritual', stratum_depth: 8, artifact_type: :ritual)
      matches = engine.cross_reference(domain: 'ritual', min_strata: 2)
      expect(matches.any? { |m| m[:content] == 'fire' }).to be true
    end

    it 'excludes content in fewer strata than min_strata' do
      bury_one(domain: 'solo', depth: 3)
      expect(engine.cross_reference(domain: 'solo', min_strata: 2)).to be_empty
    end
  end

  describe '#deepest_artifacts' do
    it 'returns artifacts sorted by depth descending' do
      bury_one(depth: 2)
      bury_one(depth: 15, content: 'ancient')
      expect(engine.deepest_artifacts(limit: 5).first[:stratum_depth]).to eq(15)
    end

    it 'respects limit' do
      3.times { |i| bury_one(depth: i, content: "item #{i}") }
      expect(engine.deepest_artifacts(limit: 2).size).to eq(2)
    end
  end

  describe '#surface_finds' do
    it 'returns artifacts from shallowest stratum' do
      bury_one(depth: 0, content: 'surface shard', pq: 0.9)
      bury_one(depth: 10, content: 'deep relic')
      results = engine.surface_finds
      expect(results.any? { |r| r[:content] == 'surface shard' }).to be true
      expect(results.none? { |r| r[:content] == 'deep relic' }).to be true
    end

    it 'returns empty when no strata exist' do
      expect(engine.surface_finds).to be_empty
    end
  end

  describe '#excavation_report' do
    it 'includes expected keys' do
      bury_one
      report = engine.excavation_report
      expect(report).to include(:strata_count, :total_artifacts, :catalog_size,
                                :avg_preservation, :preservation_label,
                                :deepest_stratum, :artifact_type_tally)
    end

    it 'counts artifacts correctly' do
      bury_one
      bury_one(content: 'second', depth: 7)
      expect(engine.excavation_report[:total_artifacts]).to eq(2)
    end

    it 'returns avg_preservation 0.0 when empty' do
      expect(engine.excavation_report[:avg_preservation]).to eq(0.0)
    end

    it 'artifact_type_tally includes all types' do
      bury_one(type: :tool)
      tally = engine.excavation_report[:artifact_type_tally]
      expect(tally).to have_key(:tool)
      expect(tally).to have_key(:fragment)
    end
  end
end
