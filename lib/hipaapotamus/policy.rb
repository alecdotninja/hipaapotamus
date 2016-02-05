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

    def self.scope(agent)
      nil
    end

    class << self
      def authorize!(agent, protected, action)
        new(agent, protected).authorize!(action)
      end

      def resolve_scope!(agent, klass)
        if SystemAgent === agent
          klass.all
        else
          scope(agent) || klass.none
        end
      end
    end
  end
end