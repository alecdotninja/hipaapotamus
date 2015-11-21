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
    let(:protected) { Hipaapotamus.without_accountability { MedicalSecret.create! } }
    let(:protected_id) { protected.id }
    # let(:very_protected) { Hipaapotamus.without_accountability { PatientSecret.create! } }
    # let(:very_protected_id) { very_protected.id }

    it 'evaluates a block in an AccountabilityContext with the provided agent' do
      Hipaapotamus.with_accountability(agent) do
        expect(Hipaapotamus::AccountabilityContext.current.agent).to eq agent
      end
    end

    it 'records all the accesses that occur within the accountability context' do
      Hipaapotamus.with_accountability(agent) do
        MedicalSecret.find_by!(id: protected_id)
      end

      action = Hipaapotamus::Action.last

      expect(action.action_type).to eq 'access'
      expect(action.action_completed?).to eq true
      expect(action.agent).to eq agent

      Hipaapotamus.without_accountability do
        expect(action.protected).to eq protected
      end
    end

    # TODO: Need to figure out how to test failed actions
    # it 'records all failed accesses that occur within the accountability context' do
    #   begin
    #     Hipaapotamus.with_accountability(agent) do
    #       PatientSecret.find_by!(id: very_protected_id)
    #     end
    #
    #   rescue AccountabilityError
    #     action = Hipaapotamus::Action.last
    #
    #     expect(action.action_type).to eq 'access'
    #     expect(action.action_completed?).to eq false
    #     expect(action.agent).to eq agent
    #
    #     Hipaapotamus.without_accountability do
    #       expect(action.protected).to eq protected
    #     end
    #   end
    # end

    it 'records all the creations that occur within the accountability context' do
      medical_secret = Hipaapotamus.with_accountability(agent) do
        MedicalSecret.create!
      end

      action = Hipaapotamus::Action.last

      expect(action.action_type).to eq 'creation'
      expect(action.action_completed?).to eq true
      expect(action.agent).to eq agent

      Hipaapotamus.without_accountability do
        expect(action.protected).to eq medical_secret
      end
    end

    it 'records all the modifications that occur within the accountability context' do
      Hipaapotamus.with_accountability(agent) do
        protected.update_attributes!({})
      end

      action = Hipaapotamus::Action.last

      expect(action.action_type).to eq 'modification'
      expect(action.action_completed?).to eq true
      expect(action.agent).to eq agent

      Hipaapotamus.without_accountability do
        expect(action.protected).to eq protected
      end
    end

    it 'records all the destructions that occur within the accountability context' do
      Hipaapotamus.with_accountability(agent) do
        protected.destroy!
      end

      action = Hipaapotamus::Action.last

      expect(action.action_type).to eq 'destruction'
      expect(action.action_completed?).to eq true
      expect(action.agent).to eq agent

      Hipaapotamus.without_accountability do
        expect(action.protected).to eq protected
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
