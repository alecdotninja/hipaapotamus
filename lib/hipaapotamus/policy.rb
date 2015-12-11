require 'hipaapotamus/accountability_error'

module Hipaapotamus
  class Policy
    attr_reader :agent, :protected

    def initialize(agent, protected)
      @agent, @protected = agent, protected
    end

    def authorized?(action)
      SystemAgent === agent || try(:"#{action}?")
    end

    def authorize!(action)
      authorized?(action) || raise(AccountabilityError, "#{agent.hipaapotamus_display_name} does not have #{action} privileges to #{protected.hipaapotamus_display_name}")
    end

    def creation?
      false
    end

    def access?
      false
    end

    def modification?
      false
    end

    def destruction?
      false
    end

    class << self
      def authorize!(agent, protected, action)
        new(agent, protected).authorize!(action)
      end
    end
  end
end