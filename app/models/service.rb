class Service < ActiveRecord::Base
	include Authorizable

	belongs_to :coordinator, class_name: 'User'
	belongs_to :administrator, class_name: 'User'
	belongs_to :representative
	belongs_to :reservation
	belongs_to :table
	belongs_to :organization

	validates :quantity, numericality: { greater_than_or_equal_to: 1 }
	validates :date, :quantity, :client, :administrator, :coordinator, :table, presence: true
	validate :administrator_clearance, :schedule_uniqueness, :ensure_reservation_integrity, :organization_equality
	validates :organization, presence: true

	after_destroy :set_reservation_status_pending!
	before_save :set_seated_completed_timestamp!, if: :status_changed?

	enum status: [:incomplete, :seated, :complete]

	# Receives a reservation object and copies its 
	# attributes into the service, also uses the 
	# reservation's id for the services' association.
#Title: self.build_from_reservation
#Input: reservation, administrator = nil, table = nil
#Input Description: Reservation to be used as template and relation to the service, Optional administrator and optional table.
#Output Description: Will build a service with the attributes of the given reservation, and establish a relatinship to the reservation, administrator and table.
#Description: Will build a service with the attributes of the given reservation, and establish a relatinship to the reservation, administrator and table
#Author: Hugo González
	def self.build_from_reservation(reservation, administrator = nil, table = nil) #method
		representative_id = reservation.representative ? reservation.representative.id : nil
		Service.new(client: reservation.client, coordinator: reservation.user,
						representative_id: representative_id, quantity: reservation.quantity,
						date: reservation.date, reservation_id: reservation.id, organization: reservation.organization,
						administrator: administrator, table: table)
	end

	# Builds the object and creates it after having the received administrator assigned to ti
#Title: self.create_from_reservation
#Input: reservation, administrator, table
#Input Description: Reservation from which the service is being created, administrator in charge of the service and the table that will be occupied.
#Output Description: Created service.
#Description: Will create a service using the given attributes.
#Author: Hugo González
	def self.create_from_reservation(reservation, administrator, table) #method
		service = Service.build_from_reservation reservation, administrator, table
		service.save
		service
	end

	# Will return all services on that day
#Title: self.by_date
#Input: date, scope
#Input Description: Date and a scope for the query, either day, week, month or year.
#Output Description: List of services
#Description: Will look for services that fit inside the given scope using the given date as reference.
#Author: Hugo González
	def self.by_date(date, scope) #method
		Service.where(date: date.method("beginning_of_#{scope}").call()..date.method("end_of_#{scope}").call())
	end

#Title: self.by_week
#Input: date
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def self.by_week(date) #method
		Service.where(date: date.beginning_of_week..date.end_of_week)
	end

#Title: self.by_month
#Input: date
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def self.by_month(date) #method
		Service.where(date: date.beginning_of_month..date.end_of_month)
	end

#Title: self.by_year
#Input: date
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def self.by_year(date) #method
		Service.where(date: date.beginning_of_year..date.end_of_year)
	end


	# Receives a user object and updates the
	# calling service to have the user as its coordinator.
#Title: coordinated_by!
#Input: user
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def coordinated_by!(user) #method
		self.update(coordinator: user)
	end

	# Returns true if the user is the 
	# services' coordinator.
#Title: coordinated_by?
#Input: user
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def coordinated_by?(user) #method
		return self.coordinator == user ? true : false
	end

	# Receives a user object and updates the
	# calling service to have the user as its administrator.
#Title: administered_by!
#Input: user
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def administered_by!(user) #method
		self.update(administrator: user)
	end

	# Returns true if the user is the 
	# services' administrator.
#Title: administered_by?
#Input: user
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def administered_by?(user) #method
		return self.administrator == user ? true : false
	end

	# Checks the administering user for the appropiate clearance.
#Title: administrator_clearance
#Input: ()
#Input Description: The user in question.
#Output Description: Boolean
#Description: Will check whether the user has enough priviledge to do administrator related actions.
#Author: Hugo González
	def administrator_clearance #method
		errors.add(:administrator, "User doesn't have administrator clearance.") unless
												 has_clearance?(administrator, "administrator") if 
												 administrator.present?
	end

	# There must not be two services using the same table at the same time
#Title: schedule_uniqueness
#Input: ()
#Input Description: Service in question.
#Output Description: Void
#Description: Will invalidate the service if there is another service on the same table on the same date.
#Author: Hugo González
	def schedule_uniqueness #method
		if incomplete?
			errors.add(:date, "Table is already occupied for that date.") if
											 Service.by_date(date, "day").where(table_id: table.id, status: "incomplete").where.not(id: id).any? if
											 date.present? && table.present?
			
		end
	end

	# 
#Title: ensure_reservation_integrity
#Input: ()
#Input Description: 
#Output Description: 
#Description: if the service has a reservation, it must not change the values
# set by the reservation (it does not check for values that can't be changed)
#Author: Hugo González
	def ensure_reservation_integrity #method
		if reservation.present?
			errors.add(:date, "Service's date has been set by the reservation.") unless date == reservation.date
		end
	end

#Title: set_reservation_status_pending!
#Input: ()
#Input Description: 
#Output Description: 
#Description: will change the reservation to pending if the service was destroyed
#Author: Hugo González
	def set_reservation_status_pending! #method
		reservation.pending! if reservation.present? && !reservation.pending?
	end

#Title: organization_equality
#Input:
#Output Description: 
#Description: Ensures that all pertinent objects related to the service belong to the same organization. 
#Author: Hugo González
	def organization_equality #method
		if administrator && organization != administrator.organization
			errors.add(:organization, "Must be the same organization as the creating administrator's.")
		end
	end


	# Function: set_seated_completed_timestamp
	# Parameters: 
	
	# Description: 
	# 	will set a timestamp with current time if
	# 	status is seated or completed
#Title: set_seated_completed_timestamp!
#Input: ()
#Input Description: 
#Output Description: 
#Description: 
#Author: Hugo González
	def set_seated_completed_timestamp! #method
		self.seated_time = DateTime.now() if status_was == "incomplete" && status == "seated"
		self.completed_time = DateTime.now() if status_was == "seated" && status == "complete"
	end
end
