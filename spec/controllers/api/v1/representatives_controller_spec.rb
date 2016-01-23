require 'rails_helper'

RSpec.describe Api::V1::RepresentativesController, type: :controller do

	describe "#GET index" do
		context "when there are 4 representatives" do
			before(:each) do
				4.times { FactoryGirl.create :representative }
				get :index
			end

			it "returns 4 records from the database" do
				representative_response = json_response
				expect(representative_response[:representatives].count).to eql 4
			end

			it { should respond_with 200 }
		end
	end

	describe "#GET show" do
		before(:each) do
			@representative = FactoryGirl.create :representative
			get :show, id: @representative.id 
		end

		it "returns the information about the representative on a hash" do
			representative_response = json_response
			expect(representative_response[:name]).to eql @representative.name
		end

		it { should respond_with 200 }
	end

	describe "POST #create" do
	    context "when is successfully created" do
	      before(:each) do
	        user = FactoryGirl.create :user
	        @representative_attributes = FactoryGirl.attributes_for :representative
	        api_authorization_header user.auth_token
	        post :create, { user_id: user.id, representative: @representative_attributes }
	      end

	      it "renders the json representation for the representative record just created" do
	        representative_response = json_response
	        expect(representative_response[:name]).to eql @representative_attributes[:name]
	      end

	      it { should respond_with 201 }
	    end
	end

	describe "PUT/PATCH #update" do
		before(:each) do
			@user = FactoryGirl.create :user
			@representative = FactoryGirl.create :representative, user: @user
		end

		context "when owner coordinator updates" do
				before(:each) do
					api_authorization_header @user.auth_token
					patch :update, { user_id: @user.id, id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
				end

				it "renders a json representation of the updated representative" do
					representative_response = json_response
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
					patch :update, { user_id: @otherUser.id, id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
				end

				it "renders a json representation of the updated representative" do
					representative_response = json_response
					expect(representative_response[:name]).to eql "New Name"
				end

				it { should respond_with 200 }
			end

			context "and has coordinator credentials" do
				before do
					patch :update, { user_id: @otherUser.id, id: @representative.id, 
										representative: { name: "New Name" } }, format: :json
				end
				
				it { should respond_with 403 }
			end
		end
	end
end
