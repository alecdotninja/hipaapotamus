require 'hipaapotamus/static_policy'

module Hipaapotamus
  class CollectionPolicy < StaticPolicy
    abstract!

    attr_reader :defended_class

    def initialize(agent, defended_class)
      @agent, @defended_class = agent, defended_class
    end

    def defended_class_name
      defended_class.name
    end
  end
end
