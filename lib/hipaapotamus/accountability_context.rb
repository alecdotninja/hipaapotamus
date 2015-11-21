require 'hipaapotamus/accountability_error'

module Hipaapotamus
  class AccountabilityContext
    THREAD_STORAGE_KEY = :hipaapotamus_active_accountability_context

    attr_reader :agent, :actions

    def initialize(agent)
      raise AccountabilityError, 'Cannot create AccountabilityContext without a valid Agent' unless agent.is_a? Agent

      @agent = agent
      @actions = []

      within { yield(self) } if block_given?
    end

    # noinspection RubyArgCount
    def record_action(protected, action_type)
      @actions << Action.new(
        agent: agent,
        protected: protected,
        action_type: action_type,
        performed_at: DateTime.now
      )
    end

    def within
      _accountability_context = Thread.current[THREAD_STORAGE_KEY]
      Thread.current[THREAD_STORAGE_KEY] = self

      begin
        yield(self)
      ensure
        Thread.current[THREAD_STORAGE_KEY] = _accountability_context
      end
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