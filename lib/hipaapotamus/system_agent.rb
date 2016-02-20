require 'singleton'
require 'hipaapotamus/agent'

module Hipaapotamus
  class SystemAgent
    include Singleton
    include Agent

    class << self
      delegate :with_accountability, to: :instance
    end
  end
end