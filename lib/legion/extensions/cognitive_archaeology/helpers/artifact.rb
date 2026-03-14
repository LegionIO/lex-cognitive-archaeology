# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        class Artifact
          include Constants
          attr_reader :id, :artifact_type, :domain, :content, :depth_level, :preservation, :integrity, :discovered_at, :origin_epoch, :contextual_links

          def initialize(artifact_type:, domain:, depth_level:, content: '', preservation: nil, integrity: nil, origin_epoch: nil)
            @id = SecureRandom.uuid
            @artifact_type = artifact_type.to_sym
            @domain = domain.to_sym
            @depth_level = depth_level.to_sym
            @content = content
            @preservation = (preservation || depth_preservation).to_f.clamp(0.0, 1.0)
            @integrity = (integrity || 0.5).to_f.clamp(0.0, 1.0)
            @discovered_at = Time.now.utc
            @origin_epoch = origin_epoch || Time.now.utc
            @contextual_links = []
          end

          def decay!(rate = PRESERVATION_DECAY)
            @preservation = (@preservation - rate).clamp(0.0, 1.0).round(10)
            @integrity = (@integrity - rate * 0.5).clamp(0.0, 1.0).round(10)
          end

          def restore!(boost = RESTORATION_BOOST)
            @preservation = (@preservation + boost).clamp(0.0, 1.0).round(10)
            @integrity = (@integrity + boost * 0.5).clamp(0.0, 1.0).round(10)
          end

          def link!(other_id)
            @contextual_links << other_id unless @contextual_links.include?(other_id)
          end

          def well_preserved? = @preservation >= WELL_PRESERVED_THRESHOLD
          def fragment? = @preservation < FRAGMENT_THRESHOLD
          def deep? = (DEPTH_LEVELS.index(@depth_level) || 0) >= 3
          def surface? = @depth_level == :surface

          def to_h
            { id: @id, artifact_type: @artifact_type, domain: @domain, depth_level: @depth_level, content: @content, preservation: @preservation.round(10), integrity: @integrity.round(10), well_preserved: well_preserved?, fragment: fragment?, deep: deep?, links: @contextual_links.size, discovered_at: @discovered_at.iso8601, origin_epoch: @origin_epoch.iso8601 }
          end

          private

          def depth_preservation
            case @depth_level
            when :surface then 0.8
            when :shallow then 0.6
            when :mid then 0.45
            when :deep then 0.3
            else 0.2
            end
          end
        end
      end
    end
  end
end
