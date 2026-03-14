# frozen_string_literal: true

require 'bundler/setup'

module Legion
  module Extensions
    module Helpers
      module Lex; end
    end

    module Core; end
  end

  module Logging
    def self.debug(*); end
    def self.info(*); end
    def self.warn(*); end
    def self.error(*); end
  end
end

require 'legion/extensions/cognitive_archaeology'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
