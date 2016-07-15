require 'rails_helper'

RSpec.describe Service, type: :model do
  let(:service) { FactoryGirl.build :service }
  subject { service }

  it { should belong_to(:coordinator) }
  it { should belong_to(:administrator) }
  it { should belong_to(:representative) }
  it { should belong_to(:reservation) }
  it { should belong_to(:table) }

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
  it { should respond_to(:table) }

  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:client) }
  it { should validate_presence_of(:administrator) }
  it { should validate_presence_of(:coordinator) }
  it { should validate_presence_of(:table) }

  it { should respond_to(:organization) }
  it { should belong_to(:organization)}
  it { should validate_presence_of(:organization) }

  describe "validates administrator's clearance" do
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

  describe "table schedules" do
    before do
      @table = FactoryGirl.create :table, number: "s1"
      @date = DateTime.now      
    end

    context "when schedule is free" do
      it "is valid" do
        @service1 = FactoryGirl.build :service, table: @table, date: @date
        expect(@service1.valid?).to be true
      end
    end

    context "when schedule is not free" do
      before do
        @service1 = FactoryGirl.create :service, table: @table, date: @date
        @service2 = FactoryGirl.build :service, table: @table, date: @date
      end

      it "is not valid" do
        expect(@service2.valid?).to be false
      end
    end
  end

  describe ".build_from_reservation" do
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

  describe ".create_from_reservation" do
    before(:each) do
      @table = FactoryGirl.create :table, number: "rc1"
      @user = FactoryGirl.create :user, credentials: "administrator"
      @reservation = FactoryGirl.create :reservation
    end

    context "when successfully created" do
      before do
        @service = Service.create_from_reservation(@reservation, @user, @table)
      end
      it "has the user assigned" do
        expect(@service.administrator).to eql @user
      end
    end
  end

  describe ".by_date" do
    before(:each) do
      @table1 = FactoryGirl.create :table, number: 11
      @table2 = FactoryGirl.create :table, number: 12
      @table3 = FactoryGirl.create :table, number: 13
      @table4 = FactoryGirl.create :table, number: 14
      @service1 = FactoryGirl.create :service, date: DateTime.new(2015, 03, 30, 3, 12, 15), table: @table1
      @service2 = FactoryGirl.create :service, date: DateTime.new(2015, 1, 12, 12, 32, 15), table: @table2
      @service3 = FactoryGirl.create :service, date: DateTime.new(2015, 1, 12, 14, 31, 55), table: @table3
      @service4 = FactoryGirl.create :service, date: DateTime.new(2015, 9, 9, 4, 33, 44), table: @table4
    end

    it "returns a json with the services on the indicated date" do
      expect(Service.by_date(DateTime.new(2015, 1, 12), "day")).to match_array([@service2, @service3])
    end
  end

  describe ".by_week" do
    before(:each) do
      @date = DateTime.new(2015, 03, 30, 3, 12, 15).beginning_of_week;
      @table1 = FactoryGirl.create :table, number: 11
      @table2 = FactoryGirl.create :table, number: 12
      @table3 = FactoryGirl.create :table, number: 13
      @table4 = FactoryGirl.create :table, number: 14
      @service1 = FactoryGirl.create :service, date: @date.prev_week, table: @table1
      @service2 = FactoryGirl.create :service, date: @date.prev_week, table: @table2
      @service3 = FactoryGirl.create :service, date: @date, table: @table1
      @service4 = FactoryGirl.create :service, date: @date, table: @table2
      @service5 = FactoryGirl.create :service, date: @date.end_of_week, table: @table1
    end

    it "returns a json with the services on the indicated week" do
      expect(Service.by_date(@date, "week")).to match_array([@service3, @service4, @service5])
    end
  end

  describe ".by_month" do
    before(:each) do
      @date = DateTime.new(2015, 03, 30, 3, 12, 15).beginning_of_week;
      @table1 = FactoryGirl.create :table, number: 11
      @table2 = FactoryGirl.create :table, number: 12
      @table3 = FactoryGirl.create :table, number: 13
      @table4 = FactoryGirl.create :table, number: 14
      @service1 = FactoryGirl.create :service, date: @date.prev_month, table: @table1
      @service2 = FactoryGirl.create :service, date: @date.prev_month, table: @table2
      @service3 = FactoryGirl.create :service, date: @date, table: @table1
      @service4 = FactoryGirl.create :service, date: @date.prev_week, table: @table2
      @service5 = FactoryGirl.create :service, date: @date.end_of_week, table: @table1
    end

    it "returns a json with the services on the indicated month" do
      expect(Service.by_date(@date, "month")).to match_array([@service3, @service4])
    end
  end

  describe ".by_year" do
    before(:each) do
      @date = DateTime.new(2015, 03, 30, 3, 12, 15).beginning_of_week;
      @table1 = FactoryGirl.create :table, number: 11
      @table2 = FactoryGirl.create :table, number: 12
      @table3 = FactoryGirl.create :table, number: 13
      @table4 = FactoryGirl.create :table, number: 14
      @service1 = FactoryGirl.create :service, date: @date.prev_year, table: @table1
      @service2 = FactoryGirl.create :service, date: @date.prev_month, table: @table2
      @service3 = FactoryGirl.create :service, date: @date, table: @table1
      @service4 = FactoryGirl.create :service, date: @date.beginning_of_month, table: @table2
      @service5 = FactoryGirl.create :service, date: @date.next_month, table: @table1
      @service6 = FactoryGirl.create :service, date: @date.next_year, table: @table1
    end

    it "returns a json with the services on the indicated year" do
      expect(Service.by_date(@date, "year")).to match_array([@service2, @service3, @service4, @service5])
    end
  end

  describe '#coordinated_by?' do
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

  describe '#administered_by?' do
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

  describe '#schedule_uniqueness' do
    before(:each) do
      @table = FactoryGirl.create :table, number: "s1"
      @date = DateTime.now
      user = FactoryGirl.create :user, credentials: "administrator"
      @service1 = FactoryGirl.create :service, table: @table, date: @date
      @service2 = FactoryGirl.build :service, table: @table, date: @date

    end

    context "when the table is available" do
      before do
        @service1.complete!
      end

      it "should be valid" do
        expect(@service2.valid?).to be true
      end

    end

    context "when the table is unavailable" do
      it "should not valid" do
        expect(@service2.valid?).to be false
      end
    end
  end

  describe "organization equality" do
    before do
      @organization = FactoryGirl.create :organization
      @user = FactoryGirl.create :administrator, organization: @organization
    end

    context "when it has the same organization as owner" do
      before do
        @service = FactoryGirl.build :service, administrator: @user, organization: @organization
      end
      it "is valid" do
        expect(@service).to be_valid
      end
    end

    context "when it has a differend organization as the owner" do
      before do
        @otherOrganization = FactoryGirl.create :organization
        @service = FactoryGirl.build :service, administrator: @user, organization: @otherOrganization
      end

      it "is invalid" do
        expect(@service).to_not be_valid
      end
    end
  end
  
end
