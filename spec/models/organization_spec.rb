require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:organization) { FactoryGirl.create :organization }
  subject { organization }

  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:services).dependent(:destroy) }
  it { should have_many(:reservations).dependent(:destroy) }
  it { should have_many(:representatives).dependent(:destroy) }
  it { should have_many(:tables).dependent(:destroy) }
  
  it { should respond_to :name }
  it { should respond_to :active }
  it { should respond_to :map }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:map)}
  it { should validate_uniqueness_of(:name) }

  describe "map" do
    let(:map) { "M 121.2,65.55 L 181.8,30.59 L 545.4,30.59 M 545.4,305.9 L 393.9,305.9 L 393.9,131.1 L 545.4,131.1" }
    let(:invalid_map) { "D 0,0 L 0,0 L 0,0 M 0,0 L 0,0 L 0,0 L 0,0 " }

    context "when the map is valid" do
      it "should allow creation" do
        organization.map = map
        expect(organization).to be_valid
      end
    end

    context "when the map is invalid" do
      before do
        organization.map = invalid_map
      end

      it "should not allow creation" do
        expect(organization).not_to be_valid
      end
    end
  end
end
