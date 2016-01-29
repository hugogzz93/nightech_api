require 'rails_helper'

RSpec.describe Service, type: :model do
  let(:service) { FactoryGirl.build :service }
  subject { service }

  it { should belong_to(:user) }
  it { should belong_to(:administrator) }
  it { should belong_to(:representative) }
  it { should belong_to(:reservation) }
  xit { should have_one(:table) }

  it { should respond_to(:client) }
  it { should respond_to(:user) }
  it { should respond_to(:administrator) }
  it { should respond_to(:representative) }
  it { should respond_to(:reservation) }
  it { should respond_to(:comment) }
  it { should respond_to(:quantity) }
  it { should respond_to(:ammount) }
  it { should respond_to(:date) }
  it { should respond_to(:status) }
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  xit { should validate_presence_of(:table) }
  xit { should respond_to(:table) }

  describe "#build_from_reservation" do
  	it "should both have the same user" do
  	end

  	it "should have the same client" do
  	end

  	it "should have the same date" do
  	end

  	it "should have the reservation's id" do
  	end
  end

  describe "table association" do
    context "when created" do
      xit "should have a table assigned" do
      end
    end
  end
end
