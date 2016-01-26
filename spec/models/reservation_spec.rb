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

		context "when status is set to pending" do
			xit "should have no service assigned" do
				# pending "service creation"
			end

			xit "should have visibility set to false" do
				# pending "service creation"
			end
		end

		context "when status is set to rejected" do

			xit "should have no service assigned" do
				# pending "service creation"
			end

			xit "should have visibility set to false" do
				# pending "service creation"
			end
		end

		context "when status is set to accepted" do
			xit "should have a service assigned" do
				# pending "service creation"
			end

			xit "service should have the same client" do
				# pending "service creation"
			end

			xit "service should have same user" do
				# pending "service creation"
			end

			xit "service should have same quantity" do
				# pending "service creation"
			end
		end
	end

	describe ".by_date" do
		before(:each) do
			@reservation1 = FactoryGirl.create :reservation, date: DateTime.new(2015, 03, 30, 3, 12, 15)
			@reservation2 = FactoryGirl.create :reservation, date: DateTime.new(2015, 1, 12, 12, 32, 15)
			@reservation3 = FactoryGirl.create :reservation, date: DateTime.new(2015, 1, 12, 14, 31, 55)
			@reservation4 = FactoryGirl.create :reservation, date: DateTime.new(2015, 9, 9, 4, 33, 44)
		end

		it "returns a json with the reservations on the indicated date" do
			expect(Reservation.by_date(DateTime.new(2015, 1, 12))).to match_array([@reservation2, @reservation3])
		end
	end

	describe "belongs_to?" do
		before(:each) do
			@user = FactoryGirl.create :user
			@reservation = FactoryGirl.create :reservation
		end

		context "when user is not the owner" do
			it " returns false" do
				expect(@reservation.belongs_to?(@user)).to be false
			end
		end

		context "when user is the owner" do
			before do
				@reservation.belongs_to!(@user)
			end

			it 'returns true' do
				expect(@reservation.belongs_to?(@user)).to be true
			end
		end
	end
end
