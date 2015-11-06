module Hipaapotamus
  class AccountabilityContext
    attr_reader :agent, :accessed_records

    # Instance Methods
    def initialize(agent)
      @agent = agent
      @accessed_records = []
    end

    def record_access(record)
      @accessed_records << record
    end
  end
end