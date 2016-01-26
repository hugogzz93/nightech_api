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

			it { should respond_with 200 }
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

			it { should respond_with 200 }
		end
	end

	describe 'POST #create' do
		before(:each) do
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
		end

		context "when successfully created" do
			before(:each) do
				@reservation_attributes = FactoryGirl.attributes_for :reservation
				post :create, reservation: @reservation_attributes
			end

			it "returns a json with reservation" do
				reservation_response = json_response[:reservation]
				expect(reservation_response[:client]).to eql @reservation_attributes[:client]
			end

			it { should respond_with 201}
		end

		context "when is not created" do
			before(:each) do
				@invalid_attributes = FactoryGirl.attributes_for :reservation
				@invalid_attributes[:quantity] = 0
				post :create, reservation: @invalid_attributes 
			end

			it "returns an errors json" do
				reservation_response = json_response
				expect(reservation_response).to have_key(:errors)
			end

			it "contains a json key with the error message" do
				reservation_response = json_response
				expect(reservation_response[:errors][:quantity]).to include "must be greater than or equal to 1"
			end

			it { should respond_with 422}

		end
	end

	describe 'PUT/PATCH #update' do
		before(:each) do
			@user = FactoryGirl.create :user
			@reservation = FactoryGirl.create :reservation, user: @user
		end

		context "when user without administrator clearance updates" do
			before(:each) do
				api_authorization_header @user.auth_token
				patch :update, { id: @reservation.id, 
									reservation: { status: "accepted" } }, format: :json
			end

			it { should respond_with 403 }
		end

		context "when updating user has administrator clearance" do
			before(:each) do
				@validUser = FactoryGirl.create :user, credentials: "administrator"
				api_authorization_header @validUser.auth_token
				patch :update, { id: @reservation.id, 
								reservation: { status: "accepted", visible: false } }, format: :json
			end
			
			it "should return a json with the correct reservation" do
				reservation_response = json_response[:reservation]
				expect(reservation_response[:id]).to eql @reservation.id
			end

			it "should return a json with the updated attributes" do
				reservation_response = json_response[:reservation]
				expect(reservation_response[:status]).to eql "accepted"
			end

			it { should respond_with 200 }

			# context "and update is unsuccessful" do
			# 	before(:each) do
			# 		@validUser = FactoryGirl.create :user, credentials: "administrator"
			# 		api_authorization_header @validUser.auth_token
			# 		patch :update, { id: @reservation.id, 
			# 						reservation: { status: "acceptede", visible: false } }, format: :json
			# 	end

			# 	it "returns an error json" do
			# 		reservation_response = json_response[:reservation]
			# 		expect(reservation_response).to have_ley(:errors)
			# 	end

			# 	it "error json has an error message" do
			# 		reservation_response = json_response[:reservation]
			# 		expect(reservation_response[:errors][:status]).to include "is invalid"
			# 	end
			# end
		end
	end

	describe 'DELETE #destroy' do
		before do
			@user = FactoryGirl.create :user
			@reservation = FactoryGirl.create :reservation
			api_authorization_header @user.auth_token
		end

		context "when destroyer is the owner" do
			before do
				@reservation.belongs_to!(@user)
				delete :destroy, id: @reservation.id
			end

			it { should respond_with 204 }
		end

		context "when destroyer has administrator clearance" do
			before do
				@user.administrator!
				delete :destroy, id: @reservation.id
			end

			it { should respond_with 204 }
		end

		context "when destroyer is not owner and does not have administrator clearance" do
			before do
				delete :destroy, id: @reservation.id
			end

			it { should respond_with 403 }
		end
	end
end
