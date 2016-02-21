require 'hipaapotamus/policy'

module Hipaapotamus
  class ControllerPolicy < Policy
    abstract!

    alias_method :controller, :defended

    collection do
      alias_method :controller_class, :defended_class
    end


    if defined?(Rails)
      include Rails.application.helpers
    end

    private

    def params
      controller.params
    end
  end
end