# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      class Client
        include Runners::CognitiveArchaeology

        def initialize
          @default_engine = Helpers::ArchaeologyEngine.new
        end
      end
    end
  end
end
