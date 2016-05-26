require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:table) { Table.new }
  subject { table }

  it { should respond_to :number }
  it { should respond_to :services }

  it { should respond_to(:organization) }
  it { should belong_to(:organization)}
  it { should validate_presence_of(:organization) }
  

  it { should validate_uniqueness_of(:number).case_insensitive }

  describe "occupied?" do
  	before(:each) do
  		@table = FactoryGirl.create :table, number: "t1"
  		@date = DateTime.now
  	end

  	context "when there is a service associated" do
  		context "on a different date" do
  			before do
		  		@service = FactoryGirl.create :service, table: @table, date: @date + 1
	  		end

  			it "returns false" do
  				expect(@table.occupied?(@date)).to be false
  			end
  		end

  		context "on the same date" do
  			before do
		  		@service = FactoryGirl.create :service, table: @table, date: @date
	  		end
  			it "returns true" do
  				expect(@table.occupied?(@date)).to be true
	  		end
  		end
  	end

  	context "when there is no service associated" do
  		it "returns false" do
			expect(@table.occupied?(@date)).to be false
  		end
  	end
  end
end
