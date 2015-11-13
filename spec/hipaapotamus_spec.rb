require 'spec_helper'

describe Hipaapotamus do
  it 'has a version number' do
    expect(Hipaapotamus::VERSION).not_to be nil
  end

  describe '.current_accountability_context' do
    it 'delegates to Hipaapotamus::AccountabilityContext.current' do
      expect(Hipaapotamus::AccountabilityContext).to receive(:current)

      Hipaapotamus.current_accountability_context
    end
  end

  describe '.current_agent' do
    it 'delegates to .current_accountability_context.agent' do
      expect(Hipaapotamus).to receive(:current_accountability_context)

      Hipaapotamus.current_agent
    end
  end

  describe '.with_accountability' do
    let(:agent) { User.create! }

    it 'evaluates a block in an AccountabilityContext with the provided agent' do
      Hipaapotamus.with_accountability(agent) do
        expect(Hipaapotamus::AccountabilityContext.current.agent).to eq agent
      end
    end
  end

  describe '.without_accountability' do
    let(:anonymous_agent) { Hipaapotamus::AnonymousAgent.instance }

    it 'evaluates a block in an AccountabilityContext with the anonymous agent' do
      expect(Hipaapotamus).to receive(:with_accountability).with(anonymous_agent)

      Hipaapotamus.without_accountability do
        # tested in .with_accountability
      end
    end
  end

end
