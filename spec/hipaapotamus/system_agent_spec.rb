require 'spec_helper'

describe Hipaapotamus::SystemAgent do
  let(:anonymous_agent) { Hipaapotamus::SystemAgent.instance }

  describe '.instance' do
    it 'returns the singleton instance for the class' do
      expect(Hipaapotamus::SystemAgent.instance).to be_a Hipaapotamus::SystemAgent
      expect(Hipaapotamus::SystemAgent.instance).to be Hipaapotamus::SystemAgent.instance
    end
  end
end