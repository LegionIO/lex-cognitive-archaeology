# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        module Constants
          MAX_ARTIFACTS = 500
          MAX_SITES = 50
          DEFAULT_PRESERVATION = 0.5
          PRESERVATION_DECAY = 0.02
          RESTORATION_BOOST = 0.15
          WELL_PRESERVED_THRESHOLD = 0.7
          FRAGMENT_THRESHOLD = 0.3
          ANCIENT_AGE_MINUTES = 60.0
          DEPTH_LEVELS = %i[surface shallow mid deep bedrock].freeze
          ARTIFACT_TYPES = %i[pattern skill knowledge memory_fragment association procedure belief schema].freeze
          DOMAINS = %i[cognitive emotional procedural semantic episodic social creative analytical].freeze
          PRESERVATION_LABELS = { (0.8..) => :pristine, (0.6...0.8) => :well_preserved, (0.4...0.6) => :weathered, (0.2...0.4) => :fragmented, (..0.2) => :dust }.freeze
          DEPTH_LABELS = { surface: :recent, shallow: :familiar, mid: :forgotten, deep: :buried, bedrock: :primordial }.freeze
          INTEGRITY_LABELS = { (0.8..) => :complete, (0.6...0.8) => :substantial, (0.4...0.6) => :partial, (0.2...0.4) => :damaged, (..0.2) => :ruined }.freeze

          def self.label_for(labels, value)
            labels.each { |range, label| return label if range.cover?(value) }
            :unknown
          end
        end
      end
    end
  end
end
