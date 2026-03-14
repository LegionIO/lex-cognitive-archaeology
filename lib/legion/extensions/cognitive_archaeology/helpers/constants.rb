# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        module Constants
          MAX_ARTIFACTS           = 500
          MAX_SITES               = 50
          EXCAVATION_DEPTH_LEVELS = %i[surface shallow mid deep bedrock].freeze
          DEFAULT_PRESERVATION    = 0.5
          PRESERVATION_DECAY      = 0.02

          ARTIFACT_TYPES = %i[pattern skill knowledge memory_fragment association procedure belief schema].freeze
          DOMAIN_TYPES   = %i[cognitive emotional procedural semantic episodic social creative analytical].freeze

          DEPTH_PRESERVATION_MODIFIER = {
            surface: 0.0, shallow: -0.1, mid: -0.2, deep: -0.35, bedrock: -0.5
          }.freeze

          PRESERVATION_LABELS = [
            [0.0..0.2, :dust], [0.2..0.4, :fragmented], [0.4..0.6, :partial],
            [0.6..0.8, :intact], [0.8..1.0, :pristine]
          ].freeze

          INTEGRITY_LABELS = [
            [0.0..0.3, :corrupted], [0.3..0.6, :degraded],
            [0.6..0.8, :coherent], [0.8..1.0, :complete]
          ].freeze

          DEPTH_LABELS = {
            surface: 'Surface Layer', shallow: 'Shallow Layer', mid: 'Mid Layer',
            deep: 'Deep Layer', bedrock: 'Bedrock Layer'
          }.freeze

          DEPTH_RARITY_WEIGHTS = {
            surface: { pattern: 30, skill: 20, knowledge: 20, memory_fragment: 15, association: 10, procedure: 3, belief: 1, schema: 1 },
            shallow: { pattern: 20, skill: 20, knowledge: 20, memory_fragment: 15, association: 10, procedure: 8, belief: 5, schema: 2 },
            mid:     { pattern: 15, skill: 15, knowledge: 15, memory_fragment: 15, association: 15, procedure: 10, belief: 8, schema: 7 },
            deep:    { pattern: 5, skill: 10, knowledge: 15, memory_fragment: 20, association: 15, procedure: 10, belief: 15, schema: 10 },
            bedrock: { pattern: 3, skill: 5, knowledge: 10, memory_fragment: 20, association: 10, procedure: 10, belief: 22, schema: 20 }
          }.freeze

          def self.label_for(table, value)
            table.each { |range, label| return label if range.cover?(value) }
            table.last.last
          end
        end
      end
    end
  end
end
