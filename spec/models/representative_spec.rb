require 'rails_helper'

RSpec.describe Representative, type: :model do
  let(:representative) { FactoryGirl.build :representative } 
  subject { representative }

  it { should respond_to(:name) }
  it { should respond_to(:user) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user_id) }

  describe '#belongs_to?' do
  	before(:each) do
  		@user = FactoryGirl.create :user
  		@representative = FactoryGirl.create :representative, user: @user
  	end

  	context "when the user is the owner of the representative" do
      it "returns false" do
        expect(@representative.belongs_to?(@user)).to be true
      end
  	end

  	context "when the user is not the owner " do
      before do
        @otherUser = FactoryGirl.create :user
      end
  		
      it "returns false" do
        expect(@representative.belongs_to?(@otherUser)).to be false
      end
  	end
  end
end
