require 'rails_helper'

RSpec.describe UsersController, type: :controller do

	describe 'GET #index' do
		before(:each) do
			@user = FactoryGirl.create :super
			@subordinate_users = FactoryGirl.create_list(:coordinator, 5, supervisor_id: @user.id, organization: @user.organization)
			FactoryGirl.create :user # user from other organization
			api_authorization_header @user.auth_token
			get :index, format: :json
			@user_response = json_response
		end

		it "should render a json containing all the subordinate users" do
			expect(@user_response).to have_key(:users)
		end

		it "should not show users of other organizations" do
			expect(@user_response[:users].count).to eql User.where(organization: @user.organization).count
		end

		it "should render a json containing all the subordinate users' attributes" do
			expect(@user_response[:users][0][:email]).to eql @subordinate_users.last.email
		end

		it { should respond_with 200 }

	end

	describe 'GET #show' do
		
		before(:each) do
			@user = FactoryGirl.create :user
			get :show, id: @user.id, format: :json
		end

		it "returns the information about a user on hash" do
			user_response = json_response[:user]
			expect(user_response[:email]).to eql @user.email
		end
		
		it { should respond_with 200 }
	end

	describe 'POST #create' do

		context "when user has valid priviledges" do
			context "when successfuly created" do
				before(:each) do
					@existing_user = FactoryGirl.create :administrator
					request.headers['Authorization'] =  @existing_user.auth_token
					@user_attributes = FactoryGirl.attributes_for :user
					post :create, {user: @user_attributes}, format: :json
					@user_response = json_response[:user]
				end

				it "renders the json representation for the user record just created" do
					expect(@user_response[:email]).to eql @user_attributes[:email]
				end

				it "belongs to the same organization as the creating user" do
					expect(@user_response[:organization][:id]).to eql @existing_user.organization.id
				end

				it { should respond_with 201 }
			end

			context "when is not created" do
				before(:each) do
			        existing_user = FactoryGirl.create :user, credentials: "administrator"
			        request.headers['Authorization'] =  existing_user.auth_token
			        #email not included
			        @invalid_user_attributes = { password: "12345678",
			                                     password_confirmation: "12345678", 
			                                     credentials: "coordinator" }
			        post :create, { user: @invalid_user_attributes }, format: :json
				    @user_response = json_response
			    end

			    it "renders an errors json" do
			        expect(@user_response).to have_key(:errors)
			    end

			    it "renders the json errors on why the user could not be created" do
	        		expect(@user_response[:errors][:email]).to include "can't be blank"
			    end

			    it {should respond_with 422}
			end
		end

		context "when user has invalid priviledges" do
			before(:each) do
				existing_user = FactoryGirl.create :coordinator
				request.headers['Authorization'] =  existing_user.auth_token
				@user_attributes = FactoryGirl.attributes_for :user, credentials: "administrator"
				post :create, {user: @user_attributes}, format: :json
				@user_response = json_response
			end

			it "should render an errors json" do
				expect(@user_response).to have_key(:errors)
			end

			it "renders the json errors on why the user could not be created" do
				expect(@user_response[:errors][:credentials]).to include "Insufficient priviledges"
			end
		end
	end

	describe 'PUT/PATCH #update' do
		before(:each) do
			@user = FactoryGirl.create :administrator
			api_authorization_header @user.auth_token
		end

		context "when user updates itself" do
			context "when user updates valid attributes" do
				context "when is successfuly updated" do
					before(:each) do
						patch :update, {id: @user.id,
										user: { email: "newemail@gmail.com" } }, format: :json
					end

					it "renders the json representation for the updated user" do
						user_response = json_response[:user]
						expect(user_response[:email]).to eql "newemail@gmail.com"
					end

					it { should respond_with 200 }
				end

				context "when is not updated" do
					before(:each) do
						patch :update, { id: @user.id, 
											user: { email: "bademai.com" } }, format: :json
					end

					it "renders an errors json" do
						user_response = json_response
						expect(user_response).to have_key(:errors)
					end

					it "renders a json error on why the user could not be created" do
						user_response = json_response
						expect(user_response[:errors][:email]).to include("is invalid")
					end

					it { should respond_with 422 }
				end
			end
		end

		context "when user updates another user" do
			context "when both users belong to the same organization" do
				before do
					@updatee = FactoryGirl.create :coordinator_given_org, organization: @user.organization
				end
				context "when super updates another user" do
					before(:each) do
						@user.super!
						patch :update, { id: @updatee.id, 
											user: { credentials: "administrator" } }, format: :json
					end

					it "returns the user json with updated attributes" do
						user_response = json_response[:user]
						expect(user_response[:credentials]).to eql "administrator"
					end
				end

				context "when non-super users update credentials" do
					before(:each) do
						patch :update, { id: @updatee.id, 
											user: { credentials: "administrator" } }
					end

					it { should respond_with 403 }
				end
			end

			context "when users belong to different organizaitons" do
				before do
					@user.super!
					@updatee = FactoryGirl.create :coordinator
					patch :update, { id: @updatee.id,
										user: { credentials: "administrator" } }, format: :json
				end

				it { should respond_with 403 }
			end

		end
	end

	describe 'DELETE #destroy' do
		before(:each) do
			@user = FactoryGirl.create :user
			api_authorization_header @user.auth_token
		end

		context "the user deletes itself" do
			before(:each) do
				delete :destroy, {id: @user.id}, format: :json
			end

			it { should respond_with 204 }
		end

		context "the user is deleted by another user" do
			context "and they belong to the same org" do
				before do
					@deletee = FactoryGirl.create :coordinator_given_org, organization: @user.organization
				end

				context "the deleting user has super credentials" do
					before do
						@user.super!
						delete :destroy, { id: @deletee.id }, format: :json
					end
				
					it { should respond_with 204 }
				end

				context "the deleting user is a supervisor of the deleted user" do
					before do
						@deletee.belongs_to!(@user)
						delete :destroy, { id: @deletee.id }, format: :json
					end

					it { should respond_with 204 }
				end

				context "the deleting user is not related to the deleted user" do
					before do
						delete :destroy, { id: @deletee.id }, format: :json
					end
					
					it { should respond_with 403 }
				end
			end

			context "and they belong to different orgs" do
				before(:each) do
					@deletee = FactoryGirl.create :user
					delete :destroy, { id: @deletee.id }, format: :json
				end

				it { should respond_with 403 }
			end
		end

	end

end
