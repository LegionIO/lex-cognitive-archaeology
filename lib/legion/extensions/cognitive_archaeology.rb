# frozen_string_literal: true

require 'securerandom'

require 'legion/extensions/cognitive_archaeology/version'
require 'legion/extensions/cognitive_archaeology/helpers/constants'
require 'legion/extensions/cognitive_archaeology/helpers/artifact'
require 'legion/extensions/cognitive_archaeology/helpers/excavation_site'
require 'legion/extensions/cognitive_archaeology/helpers/archaeology_engine'
require 'legion/extensions/cognitive_archaeology/runners/cognitive_archaeology'
require 'legion/extensions/cognitive_archaeology/client'

module Legion
  module Extensions
    module CognitiveArchaeology
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
