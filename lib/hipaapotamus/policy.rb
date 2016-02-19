require 'hipaapotamus/accountability_error'
require 'hipaapotamus/agent'
require 'hipaapotamus/system_agent'

module Hipaapotamus
  class Policy
    attr_reader :agent, :protected

    delegate :protected_class, :protected_class_name, to: :class

    def self.scope(agent)
      protected_class.none
    end

    def initialize(agent, protected)
      raise 'Expected an instance of Hipaapotamus::Agent for agent' unless Agent === agent
      raise "Expected an instance of #{protected_class_name} for protected" unless protected_class === protected

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

    def permitted_attributes
      []
    end

    class << self
      def protected_class_name
        @protected_class_name ||= name.chomp('Policy') if name.ends_with?('Policy')
      end

      def protected_class
        @protected_class ||= protected_class_name.constantize
      end

      def authorize!(agent, protected, action)
        new(agent, protected).authorize!(action)
      end

      def permitted_attributes(agent, protected)
        if SystemAgent === agent
          :permit_all_attributes
        else
          new(agent, protected).permitted_attributes || []
        end
      end

      def resolve_scope(agent)
        if SystemAgent === agent
          protected_class.all
        else
          scope(agent) || protected_class.none
        end
      end

      private

      def protected_class_protected_instance_method_name
        @protected_class_instance_method_name ||= protected_class.name.demodulize.underscore.to_sym
      end

      def inherited(subclass)
        subclass.module_eval do
          unless method_defined?(protected_class_protected_instance_method_name)
            alias_method protected_class_protected_instance_method_name, :protected
          end
        end

        super
      end
    end
  end
end