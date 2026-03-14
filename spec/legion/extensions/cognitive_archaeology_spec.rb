# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::CognitiveArchaeology do
  it 'has a version number' do
    expect(Legion::Extensions::CognitiveArchaeology::VERSION).not_to be_nil
  end

  it 'has a version that is a string' do
    expect(Legion::Extensions::CognitiveArchaeology::VERSION).to be_a(String)
  end
end
