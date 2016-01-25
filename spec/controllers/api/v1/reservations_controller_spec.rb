require 'rails_helper'

RSpec.describe Api::V1::ReservationsController, type: :controller do

	describe "GET #index" do
		context "when user has administrator clearance" do
			before(:each) do
				@user = FactoryGirl.create :user, credentials: "administrator"
				api_authorization_header @user.auth_token
				@date = DateTime.new(2015, 06, 13)
				2.times { FactoryGirl.create :reservation } #Fodder reservationss
				# target reservations
				@reservation1 = FactoryGirl.create :reservation, date: DateTime.new(2015, 06, 13)
				@reservation2 = FactoryGirl.create :reservation, date: DateTime.new(2015, 06, 13)
				get :index, date: @date.utc.to_s, format: :json
			end

			it "returns the correct ammount of reservations" do
				reservation_response = json_response[:reservations]
				expect(reservation_response.count).to eql 2
			end

			it "returns the correct reservations" do
				reservation_response = json_response[:reservations]
				expect(reservation_response[0][:client]).to eql @reservation1.client
			end

			it { should respond_with 201 }
		end

		context "when user has coordinator credentials" do
			before(:each) do
				@user = FactoryGirl.create :user
				api_authorization_header @user.auth_token
				@date = DateTime.new(2015, 03, 13)
				# Reservation2 with wrong owner
				FactoryGirl.create :reservation
				# Reservation with wrong date
				FactoryGirl.create :reservation, user: @user, date: DateTime.new(2020, 03, 03)
				# Target reservations
				@reservation1 = FactoryGirl.create :reservation, user: @user, date: @date
				@reservation2 = FactoryGirl.create :reservation, user: @user, date: @date
				get :index, date: DateTime.new(2015, 3, 13).utc.to_s
			end

			it "returns only reservations that he created" do
				reservation_response = json_response[:reservations]
				expect(reservation_response.count).to eql 2
			end

			it "returns the correct reservations" do
				reservation_response = json_response[:reservations]
				expect(reservation_response[0][:client]).to eql @reservation1.client
			end

			it { should respond_with 201 }
		end
	end

end
