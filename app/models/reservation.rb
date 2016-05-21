class Reservation < ActiveRecord::Base
	belongs_to :user
	belongs_to :representative
	has_one :service

	validates :client, :user, :date, presence: :true
	validates :quantity, numericality: {greater_than_or_equal_to: 1}
	after_update :status_change_handler

	# after_update :invisible! if :pending?

	enum status: [:pending, :accepted, :rejected]
	
	# Function: .by_date
	# Parameters: date
	# 	datetime value indicating the day to be queried
	# Returns: array of Reservation objects
	
	# Description: 
	# 	Will return all the reservations for the indicated day
	def self.by_date(date)
		Reservation.where(date: date.beginning_of_day..date.end_of_day)
	end

	def belongs_to?(user)
		return self.user_id == user.id ? true : false
	end

	def belongs_to!(user)
		self.update(user_id: user.id)
	end

	def visible?
		return visible
	end

	def visible!
		self.update(visible: true)
	end

	def invisible!
		self.update(visible: false)
	end

	def toggleVisibility!
		self.update(visible: !self.visible?)
	end

	# Function: status_change_handler
	# Parameters: 
	
	# Description: 
	# 	will delete services if the status changes from 
	# 	accepted to pending
	def status_change_handler
		service.destroy if pending? && service
	end
end
