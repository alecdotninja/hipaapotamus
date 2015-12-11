require 'hipaapotamus/accountability_error'

module Hipaapotamus
  class AccountabilityContext
    THREAD_STORAGE_KEY = :hipaapotamus_active_accountability_context

    attr_reader :agent, :parent_accountability_context, :progenitor_actions

    def initialize(agent)
      raise AccountabilityError, 'Cannot create AccountabilityContext without a valid Agent' unless agent.is_a? Agent

      @agent = agent
      @open = true
      @finalized = false

      within { yield(self) } if block_given?
    end

    def open?
      @open
    end

    # noinspection RubyArgCount
    def record_action(protected, action_type, transactional = false)
      action = Action.new(
        agent: agent,
        protected: protected,
        action_type: action_type,
        source_transaction_state: Hipaapotamus.current_transaction_state,
        is_transactional: transactional,
        performed_at: DateTime.now
      )

      actions << action
    end

    def finalized?
      @finalized
    end

    def finalize!
      raise(AccountabilityError, 'AccountabilityContext is open') if open?
      raise(AccountabilityError, 'AccountabilityContext is finalized') if finalized?

      Action.bulk_insert(log_worthy_actions) if root?

      @finalized = true
    end

    def root?
      parent_accountability_context.nil?
    end

    def within
      raise(AccountabilityError, 'AccountabilityContext is not open') unless open?
      @open = false

      @parent_accountability_context = Thread.current[THREAD_STORAGE_KEY]
      Thread.current[THREAD_STORAGE_KEY] = self

      begin

        yield(self)
      ensure
        Thread.current[THREAD_STORAGE_KEY] = @parent_accountability_context
      end
    end

    protected

    def actions
      raise(AccountabilityError, 'AccountabilityContext is open') if open?

      @actions ||= if root?
        []
      else
        parent_accountability_context.actions
      end
    end

    private

    def log_worthy_actions
      actions.select(&:log_worthy?)
    end

    class << self
      def current
        Thread.current[THREAD_STORAGE_KEY]
      end

      def current!
        current || raise(AccountabilityError, 'Not within an AccountabilityContext')
      end
    end
  end
end