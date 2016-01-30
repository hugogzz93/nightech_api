require 'rails_helper'

RSpec.describe User, type: :model do
  before { @user = FactoryGirl.build(:user) }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:auth_token) }
  it { should respond_to(:credentials) }
  it { should respond_to(:representatives) }
  it { should have_many(:representatives) }
  it { should have_many(:reservations) }
  it { should have_many(:coordinated_services) }
  it { should have_many(:administered_services) }

  it { should be_valid }

  it { should validate_presence_of(:email) }
  # it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:auth_token) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@domain.com').for(:email) }

  describe "#generate_authentication_token!" do
    
    it "generates a unique authentication token" do
      Devise.stub(:friendly_token).and_return("auniquetoken123")
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql "auniquetoken123"
    end

    it "generates another token when one is already taken" do
      existing_user = FactoryGirl.create :user, auth_token: "auniquetoken123"
      @user.generate_authentication_token!
      expect(@user.auth_token).not_to eql existing_user.auth_token
    end
  end

  describe "#outranks?" do

    it "returns true when user has higher credentials of created user " do
      existing_user = FactoryGirl.create :user, credentials: "administrator"
      new_user = FactoryGirl.build :user, credentials: "coordinator"
      expect(existing_user.can_create?(new_user)).to be true
    end

    it "returns false when user has lower credentials of created user" do
      existing_user = FactoryGirl.create :user, credentials: "coordinator"
      new_user = FactoryGirl.build :user, credentials: "administrator"
      expect(existing_user.can_create?(new_user)).to be false
    end
  end

  describe "#belongs_to?" do
    context "when user creates new_user" do
      before do
        @user.administrator!
        @new_user = @user.subordinates.create(FactoryGirl.attributes_for :user)
      end

      it "returns true" do
        expect(@new_user.belongs_to?(@user)).to be true
      end
    end

    context "when user does not create new_user" do
      before do
        @user.administrator!
        @new_user =  FactoryGirl.create :user
      end

      it "returns false" do
        expect(@new_user.belongs_to?(@user)).to be false
      end
    end
  end

  describe "#representatives association" do

    before do
      @user.save
      3.times { FactoryGirl.create :representative, user: @user }
    end

    it "destroys the associated representatives on self destruct" do
      representatives = @user.representatives
      @user.destroy
      representatives.each do |representative|
        expect(representative.find(representative)).to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  
end
