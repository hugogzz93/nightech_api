require 'rails_helper'

RSpec.describe Api::V1::ServicesController, type: :controller do
	
	describe 'GET #index' do
		before(:each) do
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
			@date = DateTime.new(2015, 06, 13)
			@service = FactoryGirl.create :service, date: @date # service on target date
			2.times { FactoryGirl.create :service, date: @date } # services on target date
			2.times { FactoryGirl.create :service } # services on wrong date
		end

		context "when user has administrator clearance" do
			before do
				@user.administrator!
				get :index, date: @date.utc.to_s, format: :json
			end

			it "returns a json with the correct ammount of services" do
				service_response = json_response[:services]
				expect(service_response.count).to eql 3
			end

			it "returns the correct services in the json" do
				service_response = json_response[:services]
				expect(service_response[0][:client]).to eql @service.client
			end

			xit "retuns its assigned table" do
			end

			it { should respond_with 200 }
		end

		context "when user does not have administrator clearance" do
			before do
				get :index, date: @date.utc.to_s, format: :json
			end

			it { should respond_with 403 }
		end
	end

	describe 'POST #create' do
		before(:each) do
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
			@date = DateTime.new(2015, 06, 13)
			@service_attributes = FactoryGirl.attributes_for :service, 
								user: nil, administrator: nil, reservation: nil, date: @date,
								status: "complete"
		end

		context "when user has administrator clearance" do
			context "and is successfully created" do
				before do
					@user.administrator!
					post :create, service: @service_attributes, format: :json
				end

				it "should return a json with the created service" do
					service_response = json_response[:service]
					expect(service_response[:client]).to eql @service_attributes[:client]
				end

				it "should belong to the creating user" do
					service_response = json_response[:service]
					expect(service_response[:user_id]).to eql @user.id
				end

				it "should have the creating user as administrator" do
					service_response = json_response[:service]
					expect(service_response[:administrator_id]).to eql @user.id
				end

				xit "returns its assigned table" do
				end

				it { should respond_with 201}
			end

			context "and it failed to be created" do
				xit "pending table implementation"
			end
		end

		context 'when user does not have administrator clearance' do
			before do
				post :create, service: @service_attributes, format: :json
			end

			it { should respond_with 403 }
		end
	end

	describe 'PUT/PATCH #update' do
		before(:each) do
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
			@date = DateTime.new(2015, 06, 13)
			@service = FactoryGirl.create :service
			# @service_attributes = { date: @date, status: "complete", ammount: "7243.12",  }
		end
		
		context "when user has administrator clearance" do
			before do
				@user.administrator!
			end

			context "and updates critical attributes" do
				# table, status, date
				context "and the update is the table" do
					xit "should update the table" do
					end
				end

				context "and the update is the status" do
					before do
						patch :update, { id: @service.id, 
											service: { status: "complete" } }, format: :json
					end

					it "returns a json with the updated service" do
						service_response = json_response[:service]
						expect(service_response[:id]).to eql @service.id
					end

					it "the attributes returned are updated" do
						service_response = json_response[:service]
						expect(service_response[:status]).to eql "complete"
					end

					it { should respond_with 200 }
				end

				context "and the update is the date" do
					before(:each) do
						@date = DateTime.new(2015, 06, 12)
						patch :update, { id: @service.id, 
											service: { date: @date } }, format: :json
					end

					context "and the service has an associated reservation" do
						it "returns an errors json" do
							service_response = json_response
							expect(service_response).to have_key(:errors)
						end

						it "returns an error message" do
							service_response = json_response
							expect(service_response[:errors][:date]).to include("Service has date from associated reservation.")
						end

						it { should respond_with 403}
					end

					context "and the service has no reservation" do
						before(:each) do
							@service.update(representative: nil)
							patch :update, { id: @service.id, 
											service: { date: @date } }, format: :json
						end

						it "responds with a json of the service" do
							service_response = json_response[:service]
							expect(service_response[:id]).to eql @service.id
						end

						it "response has updated attributes" do
							service_response = json_response[:service]
							expect(service_response[:date]).to eql @date.utc.to_s
						end

						it { should respond_with 200 }
					end
				end
			end

			context "and updates non-critical attributes" do
				# quantity, ammount
				before do
					patch :update, { id: @service.id, 
											service: { quantity: "4" } }, format: :json
				end

				it "responds with a json of the service" do
					service_response = json_response[:service]
					expect(service_response[:id]).to eql @service.id
				end

				it "the response has updated attributes" do
					service_response = json_response[:service]
					expect(service_response[:quantity]).to eql "4"
				end

				it { should respond_with 200 }
			end
		end

		context "when user does not have administrator clearance" do
			before do
				patch :update, { id: @service.id, 
											service: { status: "complete" } }, format: :json	
			end

			it { should respond_with 403 }
		end
	end

	describe 'DELETE #destroy' do
		before(:each) do
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
			@service = FactoryGirl.create :service
		end

		context "when the user has administrator clearance" do
			before do
				@user.administrator!
				delete :destroy, id: @service.id, format: :json
			end

			context "and the service has a reservation" do
				before do
					@reservation = FactoryGirl.create :reservation, user: @user, status: "accepted"
					@service.update(reservation: @reservation)
				end

				it "updates the reservation to pending" do
					expect(@reservation.status).to eql "pending"
				end
			end

			it { should respond_with 204 }

		end

		context "when the user does not have administrator clearance" do
			before do
				delete :destroy, id: @service.id, format: :json
			end

			it { should respond_with 403 }
		end
	end
end
