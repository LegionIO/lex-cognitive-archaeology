# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Helpers
        class ArchaeologyEngine
          include Constants

          def initialize
            @sites     = {}
            @artifacts = {}
          end

          def create_site(domain:)
            raise ArgumentError, "site capacity reached (max #{MAX_SITES})" if @sites.size >= MAX_SITES

            site = ExcavationSite.new(domain: domain)
            @sites[site.id] = site
            site
          end

          def dig(site_id:)
            site = fetch_site!(site_id)
            { site: site.survey, dug: site.dig_deeper! }
          end

          def excavate(site_id:)
            raise ArgumentError, 'artifact capacity reached' if @artifacts.size >= MAX_ARTIFACTS

            site = fetch_site!(site_id)
            artifact = site.excavate!
            @artifacts[artifact.id] = artifact
            artifact
          end

          def restore_artifact(artifact_id:, boost: 0.15)
            artifact = fetch_artifact!(artifact_id)
            artifact.restore!(boost: boost)
            artifact
          end

          def decay_all!(rate: PRESERVATION_DECAY)
            @artifacts.each_value { |a| a.decay!(rate: rate) }
            @artifacts.delete_if { |_, a| a.preservation <= 0.0 }
            @artifacts.size
          end

          def artifacts_by_type(type) = @artifacts.values.select { |a| a.type == type.to_sym }
          def artifacts_by_domain(domain) = @artifacts.values.select { |a| a.domain == domain.to_sym }
          def artifacts_by_depth(depth) = @artifacts.values.select { |a| a.depth_level == depth.to_sym }
          def all_artifacts = @artifacts.values
          def all_sites = @sites.values

          def best_preserved(limit: 10)
            @artifacts.values.sort_by { |a| -a.preservation }.first(limit)
          end

          def most_fragile(limit: 10)
            @artifacts.values.select(&:fragment?).sort_by(&:preservation).first(limit)
          end

          def site_report(site_id:) = fetch_site!(site_id).to_h

          def archaeology_report
            {
              total_artifacts:  @artifacts.size,
              total_sites:      @sites.size,
              type_breakdown:   count_by(:type, ARTIFACT_TYPES),
              domain_breakdown: count_by(:domain, DOMAIN_TYPES),
              depth_breakdown:  count_by(:depth_level, EXCAVATION_DEPTH_LEVELS),
              avg_preservation: avg_metric(:preservation),
              avg_integrity:    avg_metric(:integrity),
              fragment_count:   @artifacts.values.count(&:fragment?)
            }
          end

          private

          def fetch_site!(id) = @sites.fetch(id) { raise ArgumentError, "site not found: #{id}" }
          def fetch_artifact!(id) = @artifacts.fetch(id) { raise ArgumentError, "artifact not found: #{id}" }

          def count_by(attr, values)
            values.to_h { |v| [v, @artifacts.values.count { |a| a.public_send(attr) == v }] }
          end

          def avg_metric(method)
            return 0.0 if @artifacts.empty?

            (@artifacts.values.sum(&method) / @artifacts.size).round(10)
          end
        end
      end
    end
  end
end
