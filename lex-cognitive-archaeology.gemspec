# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_archaeology/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-archaeology'
  spec.version       = Legion::Extensions::CognitiveArchaeology::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Cognitive archaeology for LegionIO'
  spec.description   = 'Excavating buried cognitive artifacts — finding deeply buried patterns ' \
                       'from the earliest layers of processing history, like real archaeology ' \
                       'digs through layers of civilization'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-archaeology'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['documentation_uri']     = "#{spec.homepage}/blob/master/README.md"
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('spec/') }
  spec.require_paths = ['lib']
end
