# frozen_string_literal: true
RSpec.describe Legion::Extensions::CognitiveArchaeology::Client do
  subject(:client) { described_class.new }

  it 'instantiates without error' do expect { described_class.new }.not_to raise_error end
  it 'responds to runner methods' do %i[create_site dig excavate restore_artifact list_artifacts archaeology_status].each { |m| expect(client).to respond_to(m) } end

  describe '#create_site' do
    it 'returns success' do r = client.create_site(domain: :cognitive); expect(r[:success]).to be true; expect(r[:site_id]).to be_a(String) end
    it 'returns domain' do expect(client.create_site(domain: :emotional)[:domain]).to eq(:emotional) end
    it 'fails for invalid domain' do r = client.create_site(domain: :nope); expect(r[:success]).to be false end
  end

  describe '#dig' do
    let(:sid) { client.create_site(domain: :cognitive)[:site_id] }
    it 'advances depth' do r = client.dig(site_id: sid); expect(r[:success]).to be true; expect(r[:new_depth]).to eq(:shallow) end
    it 'fails for unknown site' do expect(client.dig(site_id: 'x')[:success]).to be false end
  end

  describe '#excavate' do
    let(:sid) { client.create_site(domain: :cognitive)[:site_id] }
    it 'excavates artifact' do r = client.excavate(site_id: sid); expect(r[:success]).to be true; expect(r[:artifact_id]).to be_a(String) end
    it 'returns type and domain' do r = client.excavate(site_id: sid); expect(r[:type]).to be_a(Symbol); expect(r[:domain]).to eq(:cognitive) end
    it 'fails for unknown site' do expect(client.excavate(site_id: 'x')[:success]).to be false end
  end

  describe '#restore_artifact' do
    let(:sid) { client.create_site(domain: :cognitive)[:site_id] }
    let(:aid) { client.excavate(site_id: sid)[:artifact_id] }
    it 'restores' do r = client.restore_artifact(artifact_id: aid); expect(r[:success]).to be true; expect(r[:preservation]).to be_a(Numeric) end
    it 'fails for unknown artifact' do expect(client.restore_artifact(artifact_id: 'x')[:success]).to be false end
  end

  describe '#list_artifacts' do
    let(:sid) { client.create_site(domain: :cognitive)[:site_id] }
    before { 3.times { client.excavate(site_id: sid) } }
    it 'returns all' do r = client.list_artifacts; expect(r[:success]).to be true; expect(r[:count]).to eq(3) end
    it 'filters by domain' do expect(client.list_artifacts(domain: :cognitive)[:artifacts]).to all(satisfy { |a| a[:domain] == :cognitive }) end
    it 'filters by depth_level' do expect(client.list_artifacts(depth_level: :surface)[:artifacts]).to all(satisfy { |a| a[:depth_level] == :surface }) end
    it 'returns empty for no match' do expect(client.list_artifacts(domain: :social)[:count]).to eq(0) end
  end

  describe '#archaeology_status' do
    it 'returns success with keys' do r = client.archaeology_status; expect(r[:success]).to be true; expect(r).to include(:total_sites, :total_artifacts, :by_type, :by_domain) end
    it 'reflects sites' do client.create_site(domain: :cognitive); client.create_site(domain: :emotional); expect(client.archaeology_status[:total_sites]).to eq(2) end
  end

  describe 'workflow' do
    it 'can dig to bedrock and excavate' do
      sid = client.create_site(domain: :semantic)[:site_id]; 4.times { client.dig(site_id: sid) }
      r = client.excavate(site_id: sid); expect(r[:depth_level]).to eq(:bedrock); expect(r[:success]).to be true
    end
    it 'deep preservation < surface preservation on average' do
      s_sid = client.create_site(domain: :cognitive)[:site_id]
      d_sid = client.create_site(domain: :cognitive)[:site_id]; 4.times { client.dig(site_id: d_sid) }
      surf  = 10.times.map { client.excavate(site_id: s_sid)[:preservation] }.sum / 10.0
      deep  = 10.times.map { client.excavate(site_id: d_sid)[:preservation] }.sum / 10.0
      expect(surf).to be > deep
    end
  end
end
