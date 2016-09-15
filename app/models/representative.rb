class Representative < ActiveRecord::Base
	include CommonValidations
	belongs_to :user
	belongs_to :organization
	has_many :reservations
	
	validates :user_id, :name, presence: true
	validates :organization, presence: true


#Title: belongs_to?
#Input: user
#Input Description: User in question of belonging.
#Output Description: Boolean
#Description: Indicates whether the representative belongs to the user.
#Author: Hugo González
	def belongs_to?(user) #method
		return self.user_id == user.id ? true : false
	end

#Title: belongs_to!
#Input: user
#Input Description: New owner.
#Output Description: Void
#Description: Changes the ownership of the representative to the User.
#Author: Hugo González
	def belongs_to!(user) #method
		self.update(user_id: user.id)
	end
end 
