module Hipaapotamus
  class Execution
    def initialize
      begin
        @value = yield
        @raised = false
      rescue StandardError => value
        @value = value
        @raised = true
      end
    end

    def raised?
      @raised
    end

    def value
      if raised?
        raise @value
      else
        @value
      end
    end
  end
end