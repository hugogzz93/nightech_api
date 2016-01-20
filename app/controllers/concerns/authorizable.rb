module Authorizable

	# Function: authorized_for_update
	# Parameters: updater, updatee, params
	# 	updater is the user performing the update
	# 	updatee is the user being updated
	#   params is the hash containing the new attributes

	# Returns: boolean indicating whether the user can update
	
	# Description: 
	# if the update changes credentials, the update will be authorized if the updater
	# has super credentials.
	# 
	# if not, the update will be authorized if the updater is super, it's a self-update or the
	# updater is the supervisor of the updatee

	def authorized_for_update(updater, updatee, params)
		return false if params.has_key?(:credentials) && !updater.super?
		return true if updater == updatee || updater.super? || updatee.belongs_to?(updater)
		return false
	end	

	# Function: authorized_for_deletion
	# Parameters: updater, updatee
	# 	updater is the user performing the deletion
	# 	updatee is the user being deleted

	# Returns: boolean indicating authorization
	
	# Description: 
	# 	The deletion will be authorzied if any of the following are true:
	# 	The updater has super credentials.
	# 	The updatee is a subordinate of the updater.
	# 	It is a self-deletion

	def authorized_for_deletion(deleter, deletee)
		return true if deleter == deletee || deleter.super? || deletee.belongs_to?(deleter)
		return false
	end
	
end