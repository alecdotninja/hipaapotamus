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
require 'hipaapotamus/record_callback_proxy'
require 'hipaapotamus/version'

module Hipaapotamus
  class << self
    def transaction_manager
      ActiveRecord::Base.connection.transaction_manager
    end

    def root_transaction
      transaction_manager.instance_exec { @stack.try(:first) } || current_transaction
    end

    def current_transaction
      transaction_manager.current_transaction
    end

    def current_transaction_state
      current_transaction.try(:state)
    end

    def current_accountability_context
      AccountabilityContext.current
    end

    def current_agent
      current_accountability_context.try(:agent)
    end

    def with_accountability(agent, &block)
      execution = nil
      accountability_context = AccountabilityContext.new(agent)

      is_using_callbacks = root_transaction.joinable?

      root_transaction.add_record RecordCallbackProxy.new accountability_context if is_using_callbacks

      accountability_context.within do
        execution = Execution.new(&block)
      end

      accountability_context.finalize! unless is_using_callbacks

      execution.try(:value)
    end

    def without_accountability(&block)
      with_accountability(AnonymousAgent.instance, &block)
    end
  end
end
