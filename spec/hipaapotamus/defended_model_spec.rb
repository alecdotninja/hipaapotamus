require 'spec_helper'

describe Hipaapotamus::DefendedModel do
  let(:agent) { User.create! }
  let(:defended) { Hipaapotamus.without_accountability { MedicalSecret.create! } }

  describe '.policy_class_name' do
    it 'returns the policy name for the class' do
      expect(MedicalSecret.policy_class_name).to eq "#{MedicalSecret.name}Policy"
    end
  end

  describe '.policy_class' do
    context 'policy class exists' do
      it 'returns the policy class of the defended model' do
        expect(MedicalSecret.policy_class).to be MedicalSecretPolicy
      end
    end

    context 'policy class does not exist' do
      it 'raises an error' do
        expect{ PolicylessModel.policy_class }.to raise_error NameError
      end
    end
  end

  describe '.policy_scoped' do
    it 'returns an ActiveRecord::Relation' do
      expect(MedicalSecret.policy_scoped).to be_an ActiveRecord::Relation
    end
  end
end