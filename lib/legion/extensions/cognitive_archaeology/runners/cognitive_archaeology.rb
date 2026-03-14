# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Runners
        module CognitiveArchaeology
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_site(domain:, engine: nil, **)
            site = resolve_engine(engine).create_site(domain: domain)
            Legion::Logging.debug "[archaeology] site #{site.id[0..7]} domain=#{domain}"
            { success: true, site: site.survey }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def dig(site_id:, engine: nil, **)
            result = resolve_engine(engine).dig(site_id: site_id)
            { success: true }.merge(result)
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def excavate(site_id:, engine: nil, **)
            artifact = resolve_engine(engine).excavate(site_id: site_id)
            { success: true, artifact: artifact.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def restore_artifact(artifact_id:, boost: 0.15, engine: nil, **)
            artifact = resolve_engine(engine).restore_artifact(artifact_id: artifact_id, boost: boost)
            { success: true, artifact: artifact.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def list_artifacts(engine: nil, type: nil, domain: nil, depth_level: nil, **)
            eng = resolve_engine(engine)
            list = if type then eng.artifacts_by_type(type)
                   elsif domain then eng.artifacts_by_domain(domain)
                   elsif depth_level then eng.artifacts_by_depth(depth_level)
                   else eng.all_artifacts
                   end
            { success: true, artifacts: list.map(&:to_h), count: list.size }
          end

          def archaeology_status(engine: nil, **)
            { success: true, report: resolve_engine(engine).archaeology_report }
          end

          private

          def resolve_engine(engine)
            engine || default_engine
          end

          def default_engine
            @default_engine ||= Helpers::ArchaeologyEngine.new
          end
        end
      end
    end
  end
end
