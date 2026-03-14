# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        class ArchaeologyEngine
          include Constants

          def initialize
            @artifacts = {}
            @sites = {}
          end

          def create_site(domain:)
            site = ExcavationSite.new(domain: domain)
            @sites[site.id] = site
            site
          end

          def dig(site_id:)
            site = @sites[site_id]
            return nil unless site
            site.dig_deeper!
            site
          end

          def excavate(site_id:)
            site = @sites[site_id]
            return nil unless site
            artifact = site.excavate!
            @artifacts[artifact.id] = artifact
            artifact
          end

          def restore_artifact(artifact_id:, boost: RESTORATION_BOOST)
            artifact = @artifacts[artifact_id]
            return nil unless artifact
            artifact.restore!(boost)
            artifact
          end

          def decay_all!
            @artifacts.each_value { |a| a.decay!(PRESERVATION_DECAY) }
          end

          def artifacts_by_domain(domain:) = @artifacts.values.select { |a| a.domain == domain.to_sym }
          def well_preserved = @artifacts.values.select(&:well_preserved?)
          def fragments = @artifacts.values.select(&:fragment?)

          def best_preserved(limit: 5)
            @artifacts.values.sort_by { |a| -a.preservation }.first(limit)
          end

          def most_fragile(limit: 5)
            @artifacts.values.sort_by(&:preservation).first(limit)
          end

          def overall_preservation
            return 0.0 if @artifacts.empty?
            (@artifacts.values.sum(&:preservation) / @artifacts.size).round(10)
          end

          def overall_integrity
            return 0.0 if @artifacts.empty?
            (@artifacts.values.sum(&:integrity) / @artifacts.size).round(10)
          end

          def depth_distribution
            dist = Hash.new(0)
            @artifacts.each_value { |a| dist[a.depth_level] += 1 }
            dist
          end

          def archaeology_report
            { total_artifacts: @artifacts.size, total_sites: @sites.size, preservation: overall_preservation, preservation_label: Constants.label_for(PRESERVATION_LABELS, overall_preservation), integrity: overall_integrity, integrity_label: Constants.label_for(INTEGRITY_LABELS, overall_integrity), well_preserved: well_preserved.size, fragments: fragments.size, depth_distribution: depth_distribution, sites: @sites.values.map(&:to_h), best_preserved: best_preserved(limit: 3).map(&:to_h) }
          end

          def to_h
            { total_artifacts: @artifacts.size, total_sites: @sites.size, preservation: overall_preservation, integrity: overall_integrity }
          end
        end
      end
    end
  end
end
