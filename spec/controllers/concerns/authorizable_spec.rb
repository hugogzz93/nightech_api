require 'rails_helper'

class Authorization < ActionController::Base
  include Authorizable
end

RSpec.describe Authorizable do
	let(:authorization) { Authorization.new }
	subject { authorization }

	describe "#has_clearance?" do
		before(:each) do
			@user = FactoryGirl.create :user, credentials: "administrator"
		end

		context "when user has higher credentials" do
			it "returns true" do
				expect(authorization.has_clearance?(@user, "coordinator")).to be true
			end
		end

		context "when user has lower credentials" do
			it "returns false" do
				expect(authorization.has_clearance?(@user, "super")).to be false
			end
		end

	end

	describe "#authorized_for_user_update" do
		context "when user is authorized" do
			before(:each) do
				@updating_user = FactoryGirl.create :user, credentials: "administrator" 
				@new_user_attributes = FactoryGirl.attributes_for :user
				@updated_user = @updating_user.subordinates.create(@new_user_attributes)
			end

			it "returns true" do
				expect(authorization.authorized_for_user_update(@updating_user, @updated_user, @new_user_attributes)).to be true
			end
		end

		context "when user is not authorized" do
			before(:each) do
				@updating_user = FactoryGirl.create :user, credentials: "administrator" 
				user = FactoryGirl.create :user, credentials: "administrator"
				@new_user_attributes = FactoryGirl.attributes_for :user
				@updated_user = user.subordinates.create(@new_user_attributes)
			end

			it "returns false" do
				expect(authorization.authorized_for_user_update(@updating_user, @updated_user, @new_user_attributes)).to be false
			end
		end

		context "when user updates itself" do
			before do
				@user = FactoryGirl.create :user, credentials: "coordinator"
				@new_user_attributes = FactoryGirl.attributes_for :user
			end

			it "returns true" do
				expect(authorization.authorized_for_user_update(@user, @user, @new_user_attributes)).to be true
			end
		end
	end

	describe "#authorized_for_user_deletion" do
		context "when the deletion is self-made" do
			before do
				@user = FactoryGirl.create :user
			end

			it "returns true" do
				expect(authorization.authorized_for_user_deletion(@user, @user)).to be true
			end
		end

		context "when the deletion is made by another user" do
			before(:each) do
				@deleter = FactoryGirl.create :user
				@deletee = FactoryGirl.create :user
			end

			context "when the deleter has super credentials" do
				before do
					@deleter.super!
				end

				it "returns true" do
					expect(authorization.authorized_for_user_deletion(@deleter, @deletee)).to be true
				end
			end

			context "when the deletee is a subordinate of the deleter" do
				before do
					@deletee.belongs_to!(@deleter)
				end
				
				it "returns true" do
					expect(authorization.authorized_for_user_deletion(@deleter, @deletee)).to be true
				end
			end

			context "when the deleter is not super and the deletee does not belong to him" do
				it "returns false" do
					expect(authorization.authorized_for_user_deletion(@deleter, @deletee)).to be false
				end
			end
		end
	end

	describe "#authorized_for_rep_update" do
		before(:each) do
			@ownerUser = FactoryGirl.create :user
			@representative = FactoryGirl.create :representative, user: @ownerUser
		end

		context "when the owner is performing the update" do
			it "returns true" do
				expect(authorization.authorized_for_rep_update(@ownerUser, @representative)).to be true
			end
		end

		context "when an administrator or higher is performing the update" do
			before(:each) do
				@otherUser = FactoryGirl.create :user, credentials: "administrator"
			end

			it "returns true" do
				expect(authorization.authorized_for_rep_update(@otherUser, @representative)).to be true
			end
		end

		context "when non-owner coordinator is performing the update" do
			before(:each) do
				@otherUser = FactoryGirl.create :user
			end

			it "returns false" do
				expect(authorization.authorized_for_rep_update(@otherUser, @representative)).to be false
			end
		end
	end

	describe "#authorized_for_rep_deletion" do
		before(:each) do
			@user = FactoryGirl.create :user
			@representative = FactoryGirl.create :representative
		end

		context "when user is the owner" do
			before do
				@representative.belongs_to! @user
			end

			it "returns true" do
				expect(authorization.authorized_for_rep_deletion(@user, @representative)).to be true
			end
		end

		context "when user is not the owner" do
			it "returns false" do
				expect(authorization.authorized_for_rep_deletion(@user, @representative)).to be false
			end
		end
	end

	describe "#authorized_for_res_update" do
		before(:each) do
			@user = FactoryGirl.create :user
			@reservation = FactoryGirl.create :reservation
		end

		context "when user does not have administrator clearance" do
			it "returns false" do
				expect(authorization.authorized_for_res_update(@user, @reservation)).to eql false
			end
		end

		context "when user has administrator clearance" do
			before do
				@user.administrator!
			end
			
			it "returns true" do
				expect(authorization.authorized_for_res_update(@user, @reservation)).to eql true
			end
		end
	end
end