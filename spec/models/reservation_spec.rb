require 'rails_helper'

RSpec.describe Reservation, type: :model do
	let(:reservation) { FactoryGirl.build :reservation }
	subject { reservation }

	it { should belong_to(:user) }
	it { should belong_to(:representative) }

	it { should respond_to(:client) }
	it { should respond_to(:user) }
	it { should respond_to(:representative) }
	it { should respond_to(:quantity) }
	it { should respond_to(:comment) }
	it { should respond_to(:date) }
	it { should respond_to(:status) }
	it { should respond_to(:visible) }
	it { should be_valid }

	it { should validate_presence_of(:client) }
	it { should validate_presence_of(:user) }
	it { should validate_presence_of(:date) }
	it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }

	describe "default values" do
		before(:each) do
			@reservation = FactoryGirl.create :reservation
		end

		context "when created" do
			it "should have status of pending" do
				expect(@reservation.status).to eql "pending"
			end

			it "should have visibility set to false" do
				expect(@reservation.visible).to be false
			end
		end
	end

	describe "service association" do
		pending "implementation"
	end


  
end
