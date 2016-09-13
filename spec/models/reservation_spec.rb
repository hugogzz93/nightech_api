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
	it { should have_one(:service) }
	it { should be_valid }

	it { should validate_presence_of(:client) }
	it { should validate_presence_of(:user) }
	it { should validate_presence_of(:date) }
	it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }

	it { should respond_to(:organization) }
  	it { should belong_to(:organization)}
  	it { should validate_presence_of(:organization) }

  	it { should be_valid }

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

	describe "toggleVisibility!" do
		before(:each) do
			@user = FactoryGirl.create :user
			@reservation = FactoryGirl.create :reservation
			@reservation.visible!
		end

		context "when it's visible" do
			before do 
				@reservation.toggleVisibility!
			end

			it "becomes invisible" do
				expect(@reservation.visible?).to be false
			end
		end

		context "when it's invisible" do
			before do
				@reservation.invisible!
				@reservation.toggleVisibility!
			end

			it "becomes visible" do
				expect(@reservation.visible?).to be true
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
	        @reservation = FactoryGirl.build :reservation, user: @user, organization: @organization
	      end
	      it "is valid" do
	        expect(@reservation).to be_valid
	      end
	    end

	    context "when it has a differend organization as the owner" do
	      before do
	        @otherOrganization = FactoryGirl.create :organization
	        @reservation = FactoryGirl.build :reservation, user: @user, organization: @otherOrganization
	      end

	      it "is invalid" do
	        expect(@reservation).to_not be_valid
	      end
	    end
  	end

	# describe "status change" do
	# 	before(:each) do
	# 		@reservation = FactoryGirl.create :reservation
	# 		@user = @reservation.user
	# 		@table = FactoryGirl.create :table
	# 	end

	# 	context "when status changes from pending to accepted" do
	# 		it "should create a service" do
	# 		end

	# 		it "should assign a valid table to the service" do
	# 		end
	# 	end

	# 	context "when status changes from pending to rejected" do
	# 		# nothing
	# 	end

	# 	context "when status changes from accepted to pending" do
	# 		it "should delete the associated service" do
	# 		end

	# 		it "should free up the table" do
	# 		end
	# 	end
	# end

end
