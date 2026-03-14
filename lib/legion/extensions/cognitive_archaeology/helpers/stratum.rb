# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        class Stratum
          include Constants

          attr_reader :depth, :epoch_name, :artifacts
          attr_accessor :sediment_density

          def initialize(depth:, epoch_name: :current, sediment_density: SEDIMENT_DENSITY_DEFAULT)
            @depth            = depth.to_i
            @epoch_name       = epoch_name.to_sym
            @sediment_density = sediment_density.to_f.clamp(0.0, 1.0)
            @artifacts        = []
          end

          def add_artifact(artifact)
            @artifacts << artifact
            artifact
          end

          def remove_artifact(artifact_id)
            @artifacts.reject! { |a| a.id == artifact_id }
          end

          def find_artifact(artifact_id)
            @artifacts.find { |a| a.id == artifact_id }
          end

          def artifacts_by_type(artifact_type)
            @artifacts.select { |a| a.artifact_type == artifact_type.to_sym }
          end

          def density_label
            Constants.label_for(DENSITY_LABELS, @sediment_density)
          end

          def to_h
            {
              depth:            @depth,
              epoch_name:       @epoch_name,
              sediment_density: @sediment_density.round(10),
              density_label:    density_label,
              artifact_count:   @artifacts.size
            }
          end
        end
      end
    end
  end
end
