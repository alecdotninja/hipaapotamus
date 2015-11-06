require 'hipaapotamus/accountability_error'

module Hipaapotamus
  class AccountabilityContext
    THREAD_STORAGE_KEY = :hipaapotamus_active_accountability_context

    # Instance Methods

    attr_reader :agent, :accessed_records

    def initialize(agent)
      @agent = agent
      @accessed_records = []

      within { yield(self) } if block_given?
    end

    def record_access(record)
      @accessed_records << record
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

    # Class methods

    def self.current
      Thread.current[THREAD_STORAGE_KEY]
    end

    def self.current!
      current || raise(AccountabilityError, 'Not within an AccountabilityContext')
    end
  end
end