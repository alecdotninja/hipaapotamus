require 'hipaapotamus/system_agent'

module Hipaapotamus
  class StaticPolicy
    attr_reader :agent

    def initialize(agent)
      @agent = agent
    end

    def authorized?(action)
      SystemAgent === agent || public_send(:"#{action}?")
    end

    def authorize!(action)
      # TODO: Write exception message
      authorized?(action) || raise(AccountabilityError, 'write me')
    end

    class << self
      def abstract?
        !!@is_abstract
      end

      def new(*)
        if abstract?
          raise 'Cannot initialize abstract policy'
        else
          unless @_concrete_prepared
            @_concrete_prepared = true
            _prepare_concrete!
          end
        end

        super
      end

      private

      def abstract!
        @is_abstract = true
      end

      def _prepare_concrete!
        nil
      end
    end
  end
end