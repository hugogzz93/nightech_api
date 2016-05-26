class Representative < ActiveRecord::Base
	belongs_to :user
	belongs_to :organization
	has_many :reservations
	
	validates :user_id, :name, presence: true
	validates :organization, presence: true


	def belongs_to?(user)
		return self.user_id == user.id ? true : false
	end

	def belongs_to!(user)
		self.update(user_id: user.id)
	end


end
