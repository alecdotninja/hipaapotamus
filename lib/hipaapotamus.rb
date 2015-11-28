require 'active_record'
require 'hipaapotamus/accountability_error'
require 'hipaapotamus/accountability_context'
require 'hipaapotamus/execution'
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
      execution = nil

      ActiveRecord::Base.transaction(requires_new: true) do
        accountability_context = AccountabilityContext.new(agent) do
          ActiveRecord::Base.transaction(requires_new: true) do
            execution = Execution.new do
              yield
            end

            raise ActiveRecord::Rollback if execution.raised?
          end
        end

        Action.bulk_insert(accountability_context.actions.select(&:new_record?))
      end

      execution.try(:value)
    rescue ActiveRecord::Rollback
      nil
    end

    def without_accountability(&block)
      with_accountability(AnonymousAgent.instance, &block)
    end
  end
end
