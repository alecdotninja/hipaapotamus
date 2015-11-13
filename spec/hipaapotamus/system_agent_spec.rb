require 'spec_helper'

describe Hipaapotamus::SystemAgent do
  let(:anonymous_agent) { Hipaapotamus::SystemAgent.instance }

  describe '.instance' do
    it 'returns the singleton instance for the class' do
      expect(Hipaapotamus::SystemAgent.instance).to be_a Hipaapotamus::SystemAgent
      expect(Hipaapotamus::SystemAgent.instance).to be Hipaapotamus::SystemAgent.instance
    end
  end

  describe '#hipaapotamus_display_name' do
    it 'returns the class name (for subclass compatibility)' do
      expect(anonymous_agent.hipaapotamus_display_name).to eq Hipaapotamus::SystemAgent.name
    end
  end
end