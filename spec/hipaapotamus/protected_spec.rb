require 'spec_helper'

describe Hipaapotamus::Protected do
  let(:agent) { User.create! }
  let(:protected) { Hipaapotamus.without_accountability { MedicalSecret.create! } }

  describe '.policy_class_name' do
    it 'returns the policy name for the class' do
      expect(MedicalSecret.policy_class_name).to eq "#{MedicalSecret.name}Policy"
    end
  end

  describe '.policy_class' do
    it 'returns the policy class of the protected model' do
      expect(MedicalSecret.policy_class).to be MedicalSecretPolicy
    end
  end

  describe '.policy_class!' do
    context 'policy class exists' do
      it 'returns the policy class of the protected model' do
        expect(MedicalSecret.policy_class!).to be MedicalSecretPolicy
      end
    end

    context 'policy class does not exist' do
      it 'raises an AccountabilityError' do
        allow(MedicalSecret).to receive(:policy_class) {nil}

        expect{ MedicalSecret.policy_class! }.to raise_error(AccountabilityError)
      end
    end
  end

  describe '.policy_scoped' do
    it 'returns an ActiveRecord::Relation' do
      expect(MedicalSecret.policy_scoped).to be_an ActiveRecord::Relation
    end
  end

  describe '#hipaapotamus_display_name' do
    context 'on new record' do
      it 'returns a string stating that it is a new record' do
        new_secret = MedicalSecret.new

        expect(new_secret.hipaapotamus_display_name).to eq "a new #{new_secret.class.name}"
      end
    end

    context 'on existing record' do
      it 'returns the class and the primary key of the record' do
        expect(protected.hipaapotamus_display_name).to eq "#{protected.class.name}(#{protected.class.primary_key}=#{protected[protected.class.primary_key]})"
      end
    end
  end
end