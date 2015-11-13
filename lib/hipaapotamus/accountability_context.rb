require 'hipaapotamus/accountability_error'

module Hipaapotamus
  class AccountabilityContext
    THREAD_STORAGE_KEY = :hipaapotamus_active_accountability_context

    attr_reader :agent, :touches

    def initialize(agent)
      raise AccountabilityError, 'Cannot create AccountabilityContext without a valid Agent' unless agent.is_a? Agent

      @agent = agent
      @touches = []

      within { yield(self) } if block_given?
    end

    def touch(record, action)
      @touches << {
        record: record,
        action: action,
        time: Time.now
      }
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