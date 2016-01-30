require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:table) { Table.new }
  subject { table }

  it { should respond_to :number }
  it { should respond_to :services }

  it { should validate_uniqueness_of(:number) }
end
