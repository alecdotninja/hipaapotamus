require 'hipaapotamus/accountability_context'
require 'hipaapotamus/accountability_error'
require 'hipaapotamus/agent'
require 'hipaapotamus/version'

module Hipaapotamus
  class << self
    def current_accountability_context
      AccountabilityContext.current
    end

    def current_agent
      current_accountability_context.try(:agent)
    end
  end
end
