require 'rails_helper'

RSpec.describe Representative, type: :model do
  let(:representative) { FactoryGirl.build :representative } 
  subject { representative }

  it { should respond_to(:name) }
  it { should respond_to(:user) }
  it { should belong_to(:user) }
  it { should belong_to(:organization) }
  it { should have_many(:reservations) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user_id) }

  it { should respond_to(:organization) }
  it { should belong_to(:organization)}
  it { should validate_presence_of(:organization) }

  it {should be_valid}

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

  describe "organization equality" do
    before do
      @organization = FactoryGirl.create :organization
      @user = FactoryGirl.create :user, organization: @organization
    end

    context "when it has the same organization as owner" do
      before do
        @representative = FactoryGirl.build :representative, user: @user, organization: @organization
      end
      it "is valid" do
        expect(@representative).to be_valid
      end
    end

    context "when it has a differend organization as the owner" do
      before do
        @otherOrganization = FactoryGirl.create :organization
        @representative = FactoryGirl.build :representative, user: @user, organization: @otherOrganization
      end

      it "is invalid" do
        expect(@representative).to_not be_valid
      end
    end
  end
  
end
