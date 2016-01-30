require 'rails_helper'

RSpec.describe Service, type: :model do
  let(:service) { FactoryGirl.build :service }
  subject { service }

  it { should belong_to(:coordinator) }
  it { should belong_to(:administrator) }
  it { should belong_to(:representative) }
  it { should belong_to(:reservation) }
  xit { should have_one(:table) }

  it { should respond_to(:client) }
  it { should respond_to(:coordinator) }
  it { should respond_to(:administrator) }
  it { should respond_to(:representative) }
  it { should respond_to(:reservation) }
  it { should respond_to(:comment) }
  it { should respond_to(:quantity) }
  it { should respond_to(:ammount) }
  it { should respond_to(:date) }
  it { should respond_to(:status) }
  xit { should respond_to(:table) }

  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:client) }
  it { should validate_presence_of(:administrator) }
  it { should validate_presence_of(:coordinator) }
  xit { should validate_presence_of(:table) }

  describe "validates administrator has administrator clearance" do
    before do
      @user = FactoryGirl.create :user
    end

    context "when user does have clearance" do
      before do
        @user.administrator!
        @service = FactoryGirl.build :service, administrator: @user, coordinator: @user
      end

      it "is valid" do
        expect(@service.valid?).to be true
      end
    end

    context "when user doesn't have clearance" do
      before do
        @service = FactoryGirl.build :service, administrator: @user, coordinator: @user
      end

      it "is invalid" do
        expect(@service.valid?).to be false
      end
    end
  end

  describe "#build_from_reservation" do
    before do
      @reservation = FactoryGirl.create :reservation
      @service = Service.build_from_reservation @reservation
    end

  	it "should both have the same user" do
      expect(@service.coordinator).to eql @reservation.user
  	end

  	it "should have the same client" do
      expect(@service.client).to eql @reservation.client
  	end

  	it "should have the same date" do
      expect(@service.date).to eql @reservation.date
  	end

  	it "should have the reservation's id" do
      expect(@service.reservation_id).to eql @reservation.id
  	end
  end

  describe "#create_from_reservation" do
    before(:each) do
      @user = FactoryGirl.create :user, credentials: "administrator"
      @reservation = FactoryGirl.create :reservation
    end

    context "when successfully created" do
      before do
        @service = Service.create_from_reservation(@reservation, @user)
      end
      it "has the user assigned" do
        expect(@service.administrator).to eql @user
      end
    end
  end

  describe '.coordinated_by?' do
    before do
      @coordinator = FactoryGirl.create :user
      @service = FactoryGirl.create :service
    end

    context "when the user is the coordinator" do
      before do
        @service.coordinated_by!(@coordinator)
      end

      it "returns true" do
        expect(@service.coordinated_by?(@coordinator)).to be true
      end
    end

    context "whent he user is not the coordinator" do
      it "returns false" do
        expect(@service.coordinated_by?(@coordinator)).to be false
      end
    end
  end

  describe '.administered_by?' do
    before(:each) do
      @user = FactoryGirl.create :user
      @service = FactoryGirl.create :service
    end

    context "when user is the administrator" do
      before do
        @service.administered_by! @user
      end

      it "should returns true" do
        expect(@service.administered_by? @user).to be true
      end
    end

    context "when user is not the administrator" do
      it "return false" do
        expect(@service.administered_by? @user).to be false
      end
    end
  end

  describe "table association" do
    context "when created" do
      xit "should have a table assigned" do
      end
    end
  end
end
