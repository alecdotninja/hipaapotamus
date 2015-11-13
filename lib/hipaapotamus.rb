require 'hipaapotamus/accountability_error'
require 'hipaapotamus/accountability_context'
require 'hipaapotamus/agent'
require 'hipaapotamus/policy'
require 'hipaapotamus/action'
require 'hipaapotamus/protected'
require 'hipaapotamus/system_agent'
require 'hipaapotamus/anonymous_agent'
require 'hipaapotamus/version'

module Hipaapotamus
  class << self
    def current_accountability_context
      AccountabilityContext.current
    end

    def current_agent
      current_accountability_context.try(:agent)
    end

    def with_accountability(agent)
      AccountabilityContext.new(agent) do
        return yield
      end
    end

    def without_accountability(&block)
      with_accountability(AnonymousAgent.instance, &block)
    end
  end
end
