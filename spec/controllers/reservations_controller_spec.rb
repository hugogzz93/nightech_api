require 'rails_helper'

RSpec.describe ReservationsController, type: :controller do

	describe "GET #index" do
		context "when user has administrator clearance" do
			before(:each) do
				@user = FactoryGirl.create :user, credentials: "administrator"
				api_authorization_header @user.auth_token
				@date = DateTime.new(2015, 06, 13)
				#Fodder reservationss
				2.times { FactoryGirl.create :reservation } 
				# target reservations
				@reservation1 = FactoryGirl.create :reservation_given_org, date: @date, organization: @user.organization
				FactoryGirl.create :reservation_given_org, date: @date, organization: @user.organization
				@reservation2 = FactoryGirl.create :reservation, date: @date
				get :index, date: @date.utc.to_s, format: :json
				@reservation_response = json_response[:reservations]
			end

			it "returns all the reservations of the same organization for that date" do
				expect(@reservation_response.count).to eql 2
			end

			it "returns the correct reservations" do
				expect(@reservation_response[0][:client]).to eql @reservation1.client
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
				# reservation with wrong organization
				FactoryGirl.create :reservation_given_org, organization: @user.organization
				# Target reservations
				@reservation1 = FactoryGirl.create :reservation, user: @user, date: @date, visible: true
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

			context "when a service has visibility set to true" do
				before(:each) do
					@administrator = FactoryGirl.create :administrator, organization: @user.organization
					@table = FactoryGirl.create :table, number: "i1"
					@service = Service.create_from_reservation @reservation1, @administrator, @table
					get :index, date: DateTime.new(2015, 3, 13).utc.to_s
				end

				it "returns the json with a table number" do
					reservation_response = json_response[:reservations]
					expect(reservation_response[0][:table_number]).to eql @table.number
				end
			end

			context "when a service has visibility set to false" do
				before(:each) do
					@administrator = FactoryGirl.create :user, credentials: "administrator"
					@table = FactoryGirl.create :table, number: "i1"
					@service = Service.create_from_reservation @reservation2, @administrator, @table
					get :index, date: DateTime.new(2015, 3, 13).utc.to_s
				end

				it "does not return a table number with the json" do
					reservation_response = json_response[:reservations]
					expect(reservation_response[1][:table_number]).to eql nil
				end
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
				@reservation_attributes = FactoryGirl.build(:reservation).attributes
				post :create, reservation: @reservation_attributes
			end

			it "returns a json with reservation" do
				reservation_response = json_response[:reservation]
				expect(reservation_response[:client]).to eql @reservation_attributes["client"]
			end

			it "belongs to the creating user" do
				reservation_response = json_response[:reservation]
				expect(reservation_response[:user_id]).to eql @user.id
			end

			it { should respond_with 201}
		end

		context "when is not created" do
			before(:each) do
				@invalid_attributes = FactoryGirl.build(:reservation).attributes
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
			@table = FactoryGirl.create :table, number: "p1"
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
			before do
				@user = FactoryGirl.create :administrator
				api_authorization_header @user.auth_token
			end
			
			context "and belongs to the same organization" do
				before do
					@user.update(organization: @reservation.organization)
					patch :update, { id: @reservation.id, 
								reservation: { status: "accepted", visible: false }, table_number: @table.number }, format: :json
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
			end

			context "and belongs to another organization" do
				before do
					patch :update, { id: @reservation.id, 
								reservation: { status: "accepted", visible: false }, table_number: @table.number }, format: :json
				end
				it {should respond_with 403}
			end

		end

		context "when status changes" do
			
			before(:each) do
				@user = FactoryGirl.create :administrator, organization: @reservation.organization
				api_authorization_header @user.auth_token
			end

			context "from pending to accepted" do
				context "and the table is available" do
					before(:each) do
						patch :update, { id: @reservation.id, 
										reservation: { status: "accepted", visible: false }, table_number: @table.number }, format: :json
						@reservation.reload
					end

					it "should have a service associated" do
						expect(@reservation.service.present?).to be true
					end

					it "should accept the reservation" do
						expect(@reservation.accepted?).to be true
					end

					it { should respond_with 200 }

					context "then changes from accepted to pending" do
						before(:each) do
							patch :update, { id: @reservation.id, 
											reservation: { status: "pending", visible: false } }, format: :json
							@reservation.reload
						end

						it "should free up the table" do
							expect(@table.occupied?(@reservation.date)).to be false
						end

						it "should destroy the associated service" do
							expect(@reservation.service.present?).to be false
						end
					end
				end

				context "and the table is unavailable" do
					before(:each) do
						@otherService = FactoryGirl.create :service, table: @table
						patch :update, { id: @reservation.id, 
										reservation: { status: "accepted", visible: false }, table_number: @table.number }, format: :json
						@reservation.reload
					end

					it "should have not a service associated" do
						expect(@reservation.service.present?).to be false
					end

					it "should retun an erros json" do
						reservation_response = json_response
						expect(reservation_response).to have_key(:errors)
					end

					it "errors json should have correct description" do
						reservation_response = json_response
						expect(reservation_response[:errors][:date]).to include "Table is already occupied for that date."
					end

					it "reservation should not be accepted" do
						expect(@reservation.accepted?).to be false
					end

					it { should respond_with 422 }
				end
			end

			context "from pending to rejected" do
				before(:each) do
					patch :update, { id: @reservation.id, 
									reservation: { status: "rejected", visible: false } }, format: :json
				end

				it "should have no service associated" do
					expect(@reservation.service.present?).to be false
				end
			end
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
				@user.update(organization: @reservation.organization)
				@reservation.belongs_to!(@user)
				delete :destroy, id: @reservation.id
			end

			it { should respond_with 204 }
		end

		context "when destroyer has administrator clearance" do
			before do
				@user.administrator!
			end

			context "and belongs to the same organization" do
				before do
					@user.update(organization: @reservation.organization)
					delete :destroy, id: @reservation.id
				end
				it { should respond_with 204 }
			end

			context "and belongs to another organization" do
				before do
					delete :destroy, id: @reservation.id
				end
				it { should respond_with 403 }
			end

		end

		context "when destroyer is not owner and does not have administrator clearance" do
			before do
				delete :destroy, id: @reservation.id
			end

			it { should respond_with 403 }
		end
	end
end
