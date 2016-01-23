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

end
