module CommonValidations
  extend ActiveSupport::Concern

  included do
  	validate :organization_equality
  end


	# Checks that the reservation has the same organization as the owner user.
	def organization_equality
		if user && organization != user.organization
			errors.add(:organization, "Must be the same organization as the creating user's.")
		end
	end
end