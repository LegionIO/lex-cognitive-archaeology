# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveArchaeology
      module Runners
        module CognitiveArchaeology
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_site(domain:, engine: nil, **)
            eng = engine || @default_engine
            site = eng.create_site(domain: domain)
            { success: true, site: site.to_h }
          end

          def dig(site_id:, engine: nil, **)
            eng = engine || @default_engine
            site = eng.dig(site_id: site_id)
            return { success: false, error: 'site not found' } unless site
            { success: true, site: site.to_h }
          end

          def excavate(site_id:, engine: nil, **)
            eng = engine || @default_engine
            artifact = eng.excavate(site_id: site_id)
            return { success: false, error: 'site not found' } unless artifact
            { success: true, artifact: artifact.to_h }
          end

          def restore_artifact(artifact_id:, boost: nil, engine: nil, **)
            eng = engine || @default_engine
            artifact = eng.restore_artifact(artifact_id: artifact_id, boost: boost || Helpers::Constants::RESTORATION_BOOST)
            return { success: false, error: 'artifact not found' } unless artifact
            { success: true, artifact: artifact.to_h }
          end

          def list_artifacts(engine: nil, **)
            eng = engine || @default_engine
            artifacts = eng.best_preserved
            { success: true, count: artifacts.size, artifacts: artifacts.map(&:to_h) }
          end

          def archaeology_status(engine: nil, **)
            eng = engine || @default_engine
            report = eng.archaeology_report
            { success: true, **report }
          end
        end
      end
    end
  end
end
