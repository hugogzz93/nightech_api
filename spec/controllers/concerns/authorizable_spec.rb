require 'rails_helper'

class Authorization < ActionController::Base
  include Authorizable
end

RSpec.describe Authorizable do
	let(:authorization) { Authorization.new }
	subject { authorization }

	# describe "#validate_user_creation" do
	# 	context "creating user has higher credentials" do
	# 		before do
	# 			@current_user = FactoryGirl.create :user, credentials: "administrator"
	# 			@new_user = FactoryGirl.build :user, credentials: "coordinator"
	# 		end

	# 		it "returns nil if creating user has higher credentials" do
	# 			expect(authorization.ensure_user_can_create(@current_user, @new_user)).to be nil
	# 		end
	# 	end

	# 	context "creating user has lower or same credentials" do
	# 		before do
	# 			@current_user = FactoryGirl.create :user, credentials: "coordinator"
	# 			@new_user = FactoryGirl.build :user, credentials: "administrator"
	# 		end

	# 		it "return false if creating user has lower or same credentials" do
	# 			expect(authorization.ensure_user_can_create(@current_user, @new_user)).to be false
	# 		end
	# 	end
	# end
	
end