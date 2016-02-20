require 'hipaapotamus/accountability_context'

module Hipaapotamus
  class AccountabilityError < StandardError
    attr_reader :accountability_context

    delegate :agent, to: :accountability_context

    def initialize(message, accountability_context = AccountabilityContext.current)
      @accountability_context = accountability_context

      super(message)
    end
  end
end
