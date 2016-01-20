require 'rails_helper'

class Authorization < ActionController::Base
  include Authorizable
end

RSpec.describe Authorizable do
	let(:authorization) { Authorization.new }
	subject { authorization }

	describe "#authorized_for_update" do
		context "when user is authorized" do
			before(:each) do
				@updating_user = FactoryGirl.create :user, credentials: "administrator" 
				@new_user_attributes = FactoryGirl.attributes_for :user
				@updated_user = @updating_user.subordinates.create(@new_user_attributes)
			end

			it "returns true" do
				expect(authorization.authorized_for_update(@updating_user, @updated_user, @new_user_attributes)).to be true
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
				expect(authorization.authorized_for_update(@updating_user, @updated_user, @new_user_attributes)).to be false
			end
		end

		context "when user updates itself" do
			before do
				@user = FactoryGirl.create :user, credentials: "coordinator"
				@new_user_attributes = FactoryGirl.attributes_for :user
			end

			it "returns true" do
				expect(authorization.authorized_for_update(@user, @user, @new_user_attributes)).to be true
			end
		end
	end

	describe "#authorized_for_deletion" do
		context "when the deletion is self-made" do
			before do
				@user = FactoryGirl.create :user
			end

			it "returns true" do
				expect(authorization.authorized_for_deletion(@user, @user)).to be true
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
					expect(authorization.authorized_for_deletion(@deleter, @deletee)).to be true
				end
			end

			context "when the deletee is a subordinate of the deleter" do
				before do
					@deletee.belongs_to!(@deleter)
				end
				
				it "returns true" do
					expect(authorization.authorized_for_deletion(@deleter, @deletee)).to be true
				end
			end

			context "when the deleter is not super and the deletee does not belong to him" do
				it "returns false" do
					expect(authorization.authorized_for_deletion(@deleter, @deletee)).to be false
				end
			end
		end
	end
end