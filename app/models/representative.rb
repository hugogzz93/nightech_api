class Representative < ActiveRecord::Base
	belongs_to :user
	has_many :reservations
	validates :user_id, :name, presence: true

	def belongs_to?(user)
		return true if self.user_id == user.id
		return false
	end

	def belongs_to!(user)
		self.update(user_id: user.id)
	end


end
