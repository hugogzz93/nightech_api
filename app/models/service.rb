class Service < ActiveRecord::Base
	include Authorizable

	belongs_to :coordinator, class_name: 'User'
	belongs_to :administrator, class_name: 'User'
	belongs_to :representative
	belongs_to :reservation

	validates :quantity, numericality: { greater_than_or_equal_to: 1 }
	validates :date, :quantity, :client, :administrator, :coordinator, presence: true
	validate :administrator_clearance

	enum status: [:incomplete, :complete]

	# Receives a reservation object and copies its 
	# attributes into the service, also uses the 
	# reservation's id for the services' association.
	def self.build_from_reservation(reservation)
		Service.new(client: reservation.client, coordinator: reservation.user,
						representative_id: reservation.representative.id, quantity: reservation.quantity,
						date: reservation.date, reservation_id: reservation.id)
	end

	# Builds the object and creates it after having the received administrator assigned to ti
	def self.create_from_reservation(reservation, administrator)
		service = Service.build_from_reservation reservation
		service.administrator = administrator
		service.save
		service
	end


	# Receives a user object and updates the
	# calling service to have the user as its coordinator.
	def coordinated_by!(user)
		self.update(coordinator: user)
	end

	# Returns true if the user is the 
	# services' coordinator.
	def coordinated_by?(user)
		return self.coordinator == user ? true : false
	end

	# Receives a user object and updates the
	# calling service to have the user as its administrator.
	def administered_by!(user)
		self.update(administrator: user)
	end

	# Returns true if the user is the 
	# services' administrator.
	def administered_by?(user)
		return self.administrator == user ? true : false
	end

	# Checks the administering user for the appropiate clearance.
	def administrator_clearance
		errors.add(:administrator, "User doesn't have administrator clearance.") unless
												 has_clearance?(administrator, "administrator") if 
												 administrator.present?
	end
end
