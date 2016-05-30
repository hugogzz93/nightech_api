require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:organization) { Organization.new }
  subject { organization }

  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:services).dependent(:destroy) }
  it { should have_many(:reservations).dependent(:destroy) }
  it { should have_many(:representatives).dependent(:destroy) }
  it { should have_many(:tables).dependent(:destroy) }
  
  it { should respond_to :name }
  it { should respond_to :active }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
