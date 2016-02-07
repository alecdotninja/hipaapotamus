require 'singleton'
require 'hipaapotamus/agent'

module Hipaapotamus
  class SystemAgent
    include Singleton
    include Agent

    def hipaapotamus_display_name
      self.class.name
    end

    class << self
      delegate :with_accountability, to: :instance
    end
  end
end