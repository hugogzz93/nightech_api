class Table < ActiveRecord::Base
	has_many :services, dependent: :destroy
	validates :number, uniqueness: true
end
