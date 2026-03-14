# frozen_string_literal: true

require 'securerandom'
require_relative 'cognitive_archaeology/version'
require_relative 'cognitive_archaeology/helpers/constants'
require_relative 'cognitive_archaeology/helpers/artifact'
require_relative 'cognitive_archaeology/helpers/excavation_site'
require_relative 'cognitive_archaeology/helpers/archaeology_engine'
require_relative 'cognitive_archaeology/runners/cognitive_archaeology'
require_relative 'cognitive_archaeology/client'

module Legion
  module Extensions
    module CognitiveArchaeology
    end
  end
end
