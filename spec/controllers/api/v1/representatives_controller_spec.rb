require 'rails_helper'

RSpec.describe Api::V1::RepresentativesController, type: :controller do
	before(:each) do
		@organization = FactoryGirl.create :organization
		@otherOrganization = FactoryGirl.create :organization
		@user = FactoryGirl.create :user, organization: @organization
		@representative = FactoryGirl.create :representative, user: @user, 
												organization: @organization
		api_authorization_header @user.auth_token
	end

	describe "GET #index" do
		context "when there are many representatives" do
			before(:each) do
				@otherUserSameOrganization = FactoryGirl.create :user, organization: @organization
				4.times { FactoryGirl.create :representative, user: @otherUserSameOrganization }
				4.times { FactoryGirl.create :representative }
				get :index
			end

			it "returns all records of the organization" do
				representative_response = json_response
				expect(representative_response[:representatives].count).to eql 5
			end

			it { should respond_with 200 }
		end
	end

	describe "GET #show" do


		context "when the representative belongs to the same organization" do
			before do
				get :show, id: @representative.id 
			end

			it "returns the information about the representative on a hash" do
				representative_response = json_response[:representative]
				expect(representative_response[:name]).to eql @representative.name
			end

			it { should respond_with 200 }
		end

		context "when the representative belongs to another organization" do
			before do
				@otherUser = FactoryGirl.create :user, organization: @otherOrganization
				@representative = FactoryGirl.create :representative, user: @otherUser
				get :show, id: @representative.id 
			end

			it { should respond_with 403 }
		end
	end

	describe "POST #create" do
	    context "when is successfully created" do
	      before(:each) do
	        @representative_attributes = (FactoryGirl.build :representative).attributes
	        post :create, { representative: @representative_attributes }
	      end

	      it "renders the json representation for the representative record just created" do
	        representative_response = json_response[:representative]
	        expect(representative_response[:name]).to eql @representative_attributes["name"]
	      end

	      it { should respond_with 201 }
	    end
	end

	describe "PUT/PATCH #update" do

		context "when owner coordinator updates" do
				before(:each) do
					patch :update, { id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
				end

				it "renders a json representation of the updated representative" do
					representative_response = json_response[:representative]
					expect(representative_response[:name]).to eql "New Name"
				end

				it { should respond_with 200 }
		end

		context "when non-owner user updates" do
			before(:each) do
				@otherUser = FactoryGirl.create :user
				api_authorization_header @otherUser.auth_token
				
			end
			context "and has administrator clearance" do
				before(:each) do
					@otherUser.administrator!
				end

				context "and belongs to the same organization" do
					before do
						@otherUser.update(organization: @organization)
						patch :update, { id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
					end
					it "renders a json representation of the updated representative" do
						representative_response = json_response[:representative]
						expect(representative_response[:name]).to eql "New Name"
					end

					it { should respond_with 200 }
				end

				context "and belongs to another organization" do
					before do
						# belongs to another organization by default
						patch :update, { id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
					end

					it {should respond_with 403}
				end
			end

			context "and has coordinator credentials" do
				before do
					patch :update, { id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
				end

				it { should respond_with 403 }
			end
		end
	end

	describe "DELETE #destroy" do

		context "when destroying user is owner" do
			before do
				delete :destroy, { id: @representative.id }
			end
			it { should respond_with 204 }
		end

		context "when destroying user is not owner" do
			before(:each) do
				@otherUser = FactoryGirl.create :user
			end

			context "and has administrator clearance" do
				before do
					@otherUser.administrator!
					api_authorization_header @otherUser.auth_token
				end

				context "and belongs to the same organization" do
					before do
						@otherUser.update(organization: @organization)
						delete :destroy, { id: @representative.id }
					end
					it { should respond_with 204 }
				end

				context "and belongs to another organization" do
					before do
						delete :destroy, { id: @representative.id }
					end
					it { should respond_with 403 }
				end
			end

			context "and does not have administrator clearance" do
				before do
					api_authorization_header @otherUser.auth_token
					delete :destroy, { id: @representative.id }
				end
				it { should respond_with 403 }
			end
		end
	end
end
