require 'hipaapotamus/static_policy'
require 'hipaapotamus/collection_policy'

module Hipaapotamus
  class Policy < StaticPolicy
    abstract!

    attr_reader :defended

    def initialize(agent, defended)
      @agent, @defended = agent, defended
    end

    class << self
      def defended_class_name
        @defended_class_name ||= name.chomp('Policy') if name.ends_with?('Policy')
      end

      def defended_class
        @defended_class ||= defended_class_name.constantize
      end

      def collection_policy_class
        @collection_policy_class ||= Class.new(superclass.try(:collection_policy_class) || CollectionPolicy)
      end

      private

      def collection(&block)
        collection_policy_class.class_eval(&block)
      end

      def defended_alias_name
        @defended_alias_name ||= defended_class.name.demodulize.underscore.to_sym
      end

      def _prepare_concrete!
        unless method_defined?(defended_alias_name)
          alias_method defended_alias_name, :defended
        end

        super
      end
    end
  end
end
