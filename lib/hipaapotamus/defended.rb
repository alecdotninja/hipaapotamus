require 'active_support/concern'

require 'hipaapotamus'

module Hipaapotamus
  module Defended
    extend ActiveSupport::Concern

    class_methods do
      def policy_class_name
        @policy_class_name ||= "#{name}Policy"
      end

      def policy_class
        @policy_class ||= policy_class_name.constantize
      end

      def policy(instance)
        policy_class.new(Hipaapotamus.current_agent, instance)
      end

      def collection_policy_class
        policy_class.collection_policy_class
      end

      def collection_policy
        collection_policy_class.new(Hipaapotamus.current_agent, self)
      end
    end

    def policy
      self.class.policy(self)
    end

    def collection_policy
      self.class.collection_policy
    end
  end
end
