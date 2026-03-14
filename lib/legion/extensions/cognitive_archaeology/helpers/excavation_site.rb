# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        class ExcavationSite
          attr_reader :id, :domain, :current_depth, :artifacts_found, :started_at

          def initialize(domain:)
            unless Constants::DOMAIN_TYPES.include?(domain.to_sym)
              raise ArgumentError,
                    "unknown domain: #{domain.inspect}; " \
                    "must be one of #{Constants::DOMAIN_TYPES.inspect}"
            end

            @id              = SecureRandom.uuid
            @domain          = domain.to_sym
            @current_depth   = Constants::EXCAVATION_DEPTH_LEVELS.first
            @artifacts_found = []
            @started_at      = Time.now.utc
          end

          def dig_deeper!
            return false if complete?

            idx            = Constants::EXCAVATION_DEPTH_LEVELS.index(@current_depth)
            @current_depth = Constants::EXCAVATION_DEPTH_LEVELS[idx + 1]
            true
          end

          def excavate!
            type     = weighted_random_type
            artifact = Artifact.new(
              type:         type,
              domain:       @domain,
              content:      "#{type}:#{@domain}@#{@current_depth}:#{SecureRandom.hex(4)}",
              depth_level:  @current_depth,
              preservation: base_preservation
            )
            @artifacts_found << artifact
            trim!
            artifact
          end

          def survey
            {
              id:              @id,
              domain:          @domain,
              current_depth:   @current_depth,
              depth_label:     Constants::DEPTH_LABELS[@current_depth],
              artifacts_count: @artifacts_found.size,
              complete:        complete?,
              started_at:      @started_at
            }
          end

          def complete?
            @current_depth == Constants::EXCAVATION_DEPTH_LEVELS.last
          end

          def to_h
            survey.merge(artifacts: @artifacts_found.map(&:to_h))
          end

          private

          def weighted_random_type
            weights    = Constants::DEPTH_RARITY_WEIGHTS[@current_depth]
            total      = weights.values.sum.to_f
            roll       = rand * total
            cumulative = 0.0
            weights.each do |t, w|
              cumulative += w
              return t if roll < cumulative
            end
            weights.keys.last
          end

          def base_preservation
            mod = Constants::DEPTH_PRESERVATION_MODIFIER.fetch(@current_depth, 0.0)
            (Constants::DEFAULT_PRESERVATION + mod + rand(-0.05..0.05)).clamp(0.0, 1.0).round(10)
          end

          def trim!
            excess = @artifacts_found.size - Constants::MAX_ARTIFACTS
            @artifacts_found.shift(excess) if excess.positive?
          end
        end
      end
    end
  end
end
