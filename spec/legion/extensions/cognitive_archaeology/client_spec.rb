# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveArchaeology::Client do
  let(:client) { described_class.new }

  it 'creates with default engine' do
    expect(client).to respond_to(:create_site)
  end

  it 'accepts injected engine' do
    engine = Legion::Extensions::CognitiveArchaeology::Helpers::ArchaeologyEngine.new
    c = described_class.new(engine: engine)
    expect(c).to respond_to(:create_site)
  end

  describe '#create_site' do
    it 'delegates to runner' do
      result = client.create_site(domain: :cognitive)
      expect(result[:success]).to be true
    end
  end

  describe '#dig' do
    it 'delegates to runner' do
      site_result = client.create_site(domain: :cognitive)
      site_id = site_result[:site][:id]
      result = client.dig(site_id: site_id)
      expect(result[:success]).to be true
    end
  end

  describe '#excavate' do
    it 'delegates to runner' do
      site_result = client.create_site(domain: :cognitive)
      site_id = site_result[:site][:id]
      result = client.excavate(site_id: site_id)
      expect(result[:success]).to be true
      expect(result[:artifact]).to be_a Hash
    end
  end

  describe '#list_artifacts' do
    it 'delegates to runner' do
      result = client.list_artifacts
      expect(result[:success]).to be true
      expect(result[:count]).to eq 0
    end
  end

  describe '#archaeology_status' do
    it 'delegates to runner' do
      result = client.archaeology_status
      expect(result[:success]).to be true
      expect(result[:report]).to be_a Hash
    end
  end
end
