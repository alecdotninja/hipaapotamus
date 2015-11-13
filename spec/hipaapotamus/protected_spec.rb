require 'spec_helper'

describe Hipaapotamus::Policy do
  let(:agent) { User.create! }
  let(:protected) { Hipaapotamus.without_accountability { MedicalSecret.create! } }

end