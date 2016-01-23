require 'rails_helper'

RSpec.describe Representative, type: :model do
  let(:representative) { FactoryGirl.build :representative } 
  subject { representative }

  it { should respond_to(:name) }
  it { should respond_to(:user) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user_id) }
end
