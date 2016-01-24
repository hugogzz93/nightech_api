class Reservation < ActiveRecord::Base
	belongs_to :user
	belongs_to :representative

	validates :client, :user, :date, presence: :true
	validates :quantity, numericality: {greater_than_or_equal_to: 1}

	enum status: [:pending, :accepted, :rejected]
end
