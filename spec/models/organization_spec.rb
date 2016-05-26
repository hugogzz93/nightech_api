require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:organization) { Organization.new }
  subject { organization }

  it { should have_many :users }
  it { should have_many :services }
  it { should have_many :reservations }
  it { should have_many :representatives }
  it { should have_many :tables }
  
  it { should respond_to :name }
  it { should respond_to :active }

  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:name) }

end
