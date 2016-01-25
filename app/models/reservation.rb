class Reservation < ActiveRecord::Base
	belongs_to :user
	belongs_to :representative

	validates :client, :user, :date, presence: :true
	validates :quantity, numericality: {greater_than_or_equal_to: 1}

	enum status: [:pending, :accepted, :rejected]
	
	# Function: .by_date
	# Parameters: date
	# 	datetime value indicating the day to be queried
	# Returns: array of Reservation objects
	
	# Description: 
	# 	Will return all the reservations for the indicated day
	def self.by_date(date)
		Reservation.where(date: date..date.end_of_day)
	end
end
