require 'hipaapotamus/accountability_error'

module Hipaapotamus
  class Policy
    attr_reader :agent, :protected

    def initialize(agent, protected)
      @agent, @protected = agent, protected
    end

    def authorize(action)
      SystemAgent === agent || try(:"#{action}?")
    end

    def authorize!(action)
      authorize(action) || raise(AccountabilityError, "#{agent.hipaapotamus_display_name} does have permission to #{action} #{protected.hipaapotamus_display_name}")
    end

    def create?
      false
    end

    def access?
      false
    end

    def update?
      false
    end

    def destroy?
      false
    end

    class << self
      def authorize!(agent, protected, action)
        new(agent, protected).authorize!(action)
      end
    end
  end
end