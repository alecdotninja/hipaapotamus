require 'singleton'
require 'hipaapotamus/agent'

module Hipaapotamus
  class SystemAgent
    include Singleton
    include Agent

    def hipaapotamus_display_name
      self.class.name
    end
  end
end