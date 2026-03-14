# frozen_string_literal: true

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
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
