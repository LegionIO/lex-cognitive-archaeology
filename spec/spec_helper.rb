# frozen_string_literal: true
require 'bundler/setup'
require 'legion/extensions/cognitive_archaeology'
module Legion
  module Extensions
    module Helpers
      module Lex; end
    end
  end
  module Logging
    def self.method_missing(_, *) = nil
    def self.respond_to_missing?(_, _ = false) = true
  end
end
RSpec.configure do |config|
  config.expect_with :rspec do |e|
    e.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |m|
    m.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  Kernel.srand config.seed
end
