require 'rails_helper'

RSpec.describe ServicesController, type: :controller do
	
	describe 'GET #index' do
		before(:each) do
			@organization = FactoryGirl.create :organization
			@user = FactoryGirl.create :user, organization: @organization
			api_authorization_header @user.auth_token
			@date = DateTime.new(2015, 06, 13)

			table1 = FactoryGirl.create :table, number: "i1"
			table2 = FactoryGirl.create :table, number: "i2"
			table3 = FactoryGirl.create :table, number: "i3"
			table4 = FactoryGirl.create :table, number: "i4"

			@service = FactoryGirl.create :service_given_org, date: @date, organization: @organization
			@service2 = FactoryGirl.create :service_given_org, date: @date, table: table1, organization: @organization
			@service3 = FactoryGirl.create :service_given_org, date: @date, table: table2, organization: @organization
			@serviceWrongOrg = FactoryGirl.create :service, date: @date
			@otherService1 = FactoryGirl.create :service_given_org, table: table3, organization: @organization
			@otherService2 = FactoryGirl.create :service_given_org, table: table4, organization: @organization

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

			it "retuns its assigned table number" do
				service_response = json_response[:services]
				expect(service_response[0][:table_number]).to eql @service.table.number
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
			@table = FactoryGirl.create :table
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
			@date = DateTime.new(2015, 06, 13)
			@service_attributes = FactoryGirl.build( :service, 
								coordinator: nil, administrator: nil, reservation: nil, date: @date,
								table: @table, status: "complete", organization: nil).attributes
		end

		context "when user has administrator clearance" do
			before do
				@user.administrator!
			end

			context "and is successfully created" do
				before do
					post :create, service: @service_attributes, format: :json
					@service_response = json_response[:service]

				end

				it "should return a json with the created service" do
					expect(@service_response[:client]).to eql @service_attributes["client"]
				end

				it "should belong to the creating user" do
					expect(@service_response[:coordinator_id]).to eql @user.id
				end

				it "should have the creating user as administrator" do
					expect(@service_response[:administrator_id]).to eql @user.id
				end

				it "returns its assigned table" do
					expect(@service_response[:table_number]).to eql @table.number
				end

				it "should belong to the same organization" do
					expect(@service_response[:organization][:id]).to eql @user.organization.id
				end

				it { should respond_with 201}
			end

			context "and it failed to be created" do
				before do
					# another service occupies the table
					@otherService = FactoryGirl.create :service, table: @table, date: @date
					post :create, service: @service_attributes, format: :json
				end

				it "returns an errors json" do
					service_response = json_response
					expect(service_response).to have_key(:errors)
				end

				it "errors message has correct description" do
					service_response = json_response
					expect(service_response[:errors][:date]).to include "Table is already occupied for that date."
				end
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
			@organization = FactoryGirl.create :organization
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
			@date = DateTime.new(2015, 06, 13)
			@service = FactoryGirl.create :service_given_org, organization: @organization
		end
		
		context "when user has administrator clearance" do
			before do
				@user.administrator!
			end

			context "and belongs to the same organization" do
				before do
					@user.update(organization: @organization)
				end

				context "and updates critical attributes" do
				# table, status, date

					context "and the update is the table" do
						before do
							@table = FactoryGirl.create :table, organization: @organization
						end

						context "and the table is available" do
							before do
								patch :update, { id: @service.id, 
													service: { table_id: @table} }, format: :json
							end

							it "should respond with a json including the new table" do
								service_response = json_response[:service]
								expect(service_response[:table_number]).to eql @table.number
							end

							it { should respond_with 200 }
						end

						context "and the table is unavailable" do
							before do
								@otherService = FactoryGirl.create :service_given_org, organization: @organization, table: @table
								patch :update, { id: @service.id, 
													service: { table_id: @table} }, format: :json
							end

							it "should respond with an errors json" do
								service_response = json_response
								expect(service_response).to have_key(:errors)
							end

							it "json should have the correct description" do
								reservation_response = json_response
								expect(reservation_response[:errors][:date]).to include "Table is already occupied for that date."
							end

							it { should respond_with 422 }
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
							@date = DateTime.new(2015, 06, 13)

						end

						context "and the service has an associated reservation" do
							before do
								user = FactoryGirl.create :administrator, organization: @organization
								reservation = FactoryGirl.create :reservation_given_org, organization: @organization
								table = FactoryGirl.create :table, number: "up1", organization: @organization
								@service = Service.create_from_reservation(reservation, user, table)
								patch :update, { id: @service.id, 
												service: { date: @date } }, format: :json
							end
							it "returns an errors json" do
								service_response = json_response
								expect(service_response).to have_key(:errors)
							end

							it "returns an error message" do
								service_response = json_response
								expect(service_response[:errors][:date]).to include("Service's date has been set by the reservation.")
							end

							it { should respond_with 422}
						end

						context "and the service has no reservation" do
							before(:each) do
								@service.update(reservation: nil)
								patch :update, { id: @service.id, 
												service: { date: @date } }, format: :json
							end

							it "responds with a json of the service" do
								service_response = json_response[:service]
								expect(service_response[:id]).to eql @service.id
							end

							it "response has updated attributes" do
								service_response = json_response[:service]
								response_date = DateTime.parse(service_response[:date])
								expect(response_date).to eql @date
							end

							it { should respond_with 200 }
						end
					end
				end
				
				context "and updates non-critical attributes" do
					# quantity, ammount
					before do
						patch :update, { id: @service.id, 
												service: { ammount: "10500" } }, format: :json
						@service_response = json_response[:service]
					end

					it "responds with a json of the service" do
						expect(@service_response[:id]).to eql @service.id
					end

					it "the response has updated attributes" do
						expect(@service_response[:ammount]).to eql "10500.0"
					end

					it { should respond_with 200 }
				end
			end

			context "and belongs to another organization" do
				before do
					patch :update, { id: @service.id, 
											service: { date: @date } }, format: :json
				end

				it { should respond_with 403 }
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
			@user = FactoryGirl.create :administrator
			api_authorization_header @user.auth_token
			@reservation = FactoryGirl.create :reservation_given_org, organization: @user.organization
			table = FactoryGirl.create :table, organization: @user.organization
			@service = Service.create_from_reservation @reservation, @user, table
		end

		context "when the user belongs to the same organization" do
			context "when the user has administrator clearance" do

				context "and the service has a reservation" do
					before do
						delete :destroy, id: @service.id, format: :json
					end

					it "updates the reservation to pending" do
						expect(@reservation.status).to eql "pending"
					end
				end

				context "and the service is completed" do
					before do
						@service.complete!
						delete :destroy, id: @service.id, format: :json
					end

					it { should respond_with 403 }
				end

				context "and the service is incomplete" do
					before do
						delete :destroy, id: @service.id, format: :json
					end

					it { should respond_with 204 }
				end
			end

			context "when the user has super clearance" do
				before do
					@user.super!
				end

				context "and the service is complete" do
					before do
						@service.complete!
						delete :destroy, id: @service.id, format: :json
					end
		
					it { should respond_with 204 }
				end

			end

			context "when the user does not have administrator clearance" do
				before do
					@user.coordinator!
					delete :destroy, id: @service.id, format: :json
				end

				it { should respond_with 403 }
			end
		end

		context "when the user belongs to another organization" do
			before do
				otherUser = FactoryGirl.create :administrator
				api_authorization_header otherUser.auth_token
				delete :destroy, id: @service.id, format: :json
			end

			it { should respond_with 403 }
		end
	end
end
