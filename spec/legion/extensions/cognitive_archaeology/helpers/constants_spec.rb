# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Helpers::Constants do
  let(:c) { described_class }

  it('MAX_ARTIFACTS') { expect(c::MAX_ARTIFACTS).to eq(500) }
  it('MAX_SITES') { expect(c::MAX_SITES).to eq(50) }
  it('DEFAULT_PRESERVATION') { expect(c::DEFAULT_PRESERVATION).to eq(0.5) }
  it('ARTIFACT_TYPES count') { expect(c::ARTIFACT_TYPES.size).to eq(8) }
  it('DOMAIN_TYPES count') { expect(c::DOMAIN_TYPES.size).to eq(8) }
  it('DEPTH_LEVELS count') { expect(c::EXCAVATION_DEPTH_LEVELS.size).to eq(5) }

  describe '.label_for' do
    it(':pristine for 0.9') { expect(c.label_for(c::PRESERVATION_LABELS, 0.9)).to eq(:pristine) }
    it(':dust for 0.1') { expect(c.label_for(c::PRESERVATION_LABELS, 0.1)).to eq(:dust) }
    it(':complete for 0.9 integrity') { expect(c.label_for(c::INTEGRITY_LABELS, 0.9)).to eq(:complete) }
  end
end
