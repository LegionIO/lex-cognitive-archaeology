# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        class Artifact
          include Constants

          attr_reader :id, :type, :domain, :content, :depth_level,
                      :discovered_at, :contextual_links
          attr_accessor :preservation, :integrity

          def initialize(type:, domain:, content:, depth_level:, preservation: nil, integrity: nil)
            @id              = SecureRandom.uuid
            @type            = type.to_sym
            @domain          = domain.to_sym
            @content         = content.to_s
            @depth_level     = depth_level.to_sym
            @preservation    = (preservation || DEFAULT_PRESERVATION).to_f.clamp(0.0, 1.0).round(10)
            @integrity       = (integrity || compute_integrity).clamp(0.0, 1.0).round(10)
            @discovered_at   = Time.now.utc
            @contextual_links = []
          end

          def decay!(rate: PRESERVATION_DECAY)
            @preservation = (@preservation - rate.abs).clamp(0.0, 1.0).round(10)
            @integrity    = (@integrity - (rate.abs * 0.5)).clamp(0.0, 1.0).round(10)
            self
          end

          def restore!(boost: 0.15)
            @preservation = (@preservation + boost.abs).clamp(0.0, 1.0).round(10)
            @integrity    = (@integrity + (boost.abs * 0.5)).clamp(0.0, 1.0).round(10)
            self
          end

          def fragment? = @preservation < 0.3
          def well_preserved? = @preservation > 0.7

          def preservation_label = Constants.label_for(PRESERVATION_LABELS, @preservation)
          def integrity_label = Constants.label_for(INTEGRITY_LABELS, @integrity)

          def link_to(other_id)
            @contextual_links << other_id unless @contextual_links.include?(other_id)
          end

          def to_h
            { id: @id, type: @type, domain: @domain, content: @content, depth_level: @depth_level,
              preservation: @preservation, preservation_label: preservation_label,
              integrity: @integrity, integrity_label: integrity_label,
              discovered_at: @discovered_at, contextual_links: @contextual_links,
              fragment: fragment?, well_preserved: well_preserved? }
          end

          private

          def compute_integrity
            mod = DEPTH_PRESERVATION_MODIFIER.fetch(@depth_level, 0.0)
            (0.8 + mod).clamp(0.0, 1.0)
          end
        end
      end
    end
  end
end
