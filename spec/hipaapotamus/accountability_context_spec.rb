require 'spec_helper'

describe Hipaapotamus::AccountabilityContext do
  let(:agent) { User.create! }
  let(:accountability_context) { Hipaapotamus::AccountabilityContext.new(agent) }
  let(:protected) { MedicalSecret.create! }

  context 'instance methods' do
    describe '#initialize' do
      it 'has a passed in agent' do
        expect(accountability_context.agent).to eq agent
      end

      it 'has no accessed records' do
        expect(accountability_context.accessed_records).to be_empty
      end
    end

    describe '#record_access' do
      it 'stores a passed in record in accessed_records' do
        accountability_context.record_access(protected)
        expect(accountability_context.accessed_records).to include(protected)
      end
    end
  end
end