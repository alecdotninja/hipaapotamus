require 'hipaapotamus/policy'
require 'hipaapotamus/system_agent'

module Hipaapotamus
  class ModelPolicy < Policy
    abstract!

    alias_method :model, :defended

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

    collection do
      alias_method :model_class, :defended_class

      def scope
        model_class.none
      end

      def resolve_scope
        if SystemAgent === agent
          model_class.all
        else
          scope || model_class.none
        end
      end
    end

    def resolve_permitted_attributes
      if SystemAgent === agent
        :permit_all_attributes
      else
        permitted_attributes || []
      end
    end
  end
end