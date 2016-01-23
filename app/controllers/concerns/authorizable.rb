module Authorizable

	# Function: has_clearance?
	# Parameters: user, credentials
	#   user: the user that is to be authorized
	# 	credentials: a string that represents a credential level for user

	# Returns: boolean
	
	# Description: 
	# 	It will return true if the user's credentials are equal or higher

	def has_clearance?(user, credentials)
	    return true if user.class.credentials[user.credentials] >= User.credentials[credentials]
	    return false
	end

	# Function: authorized_for_user_update
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

	def authorized_for_user_update(updater, updatee, params)
		return false if params.has_key?(:credentials) && !updater.super?
		return true if updater == updatee || updater.super? || updatee.belongs_to?(updater)
		return false
	end	

	# Function: authorized_for_user_deletion
	# Parameters: updater, updatee
	# 	updater is the user performing the deletion
	# 	updatee is the user being deleted

	# Returns: boolean indicating authorization
	
	# Description: 
	# 	The deletion will be authorzied if any of the following are true:
	# 	The updater has super credentials.
	# 	The updatee is a subordinate of the updater.
	# 	It is a self-deletion

	def authorized_for_user_deletion(deleter, deletee)
		return true if deleter == deletee || deleter.super? || deletee.belongs_to?(deleter)
		return false
	end

	# Function: authorized_for_rep_update
	# Parameters: updater, representative
	# 	updater is the user performing the update

	# Returns: boolean indiciating authorization
	
	# Description: 
	# 	will return true if the updater is the owner of the
	# 	representative or if it has credentials of administrator or
	# 	higher

	def authorized_for_rep_update(updater, representative)
		return true if representative.belongs_to?(updater) || has_clearance?(updater, "administrator")
		return false
	end

	# Function: authorized_for_rep_update
	# Parameters: deleter, representative
	# 	deleter is the user performing the deletion

	# Returns: boolean indiciating authorization
	
	# Description: 
	# 	will return true if the deleter is the owner of the
	# 	representative or if it has credentials of administrator or
	# 	higher

	def authorized_for_rep_deletion(deleter, representative)
		return true if representative.belongs_to?(deleter) || has_clearance?(deleter, "administrator")
		return false
	end
	
end