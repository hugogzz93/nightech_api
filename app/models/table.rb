class Table < ActiveRecord::Base
	has_many :services, dependent: :destroy
	validates :number, uniqueness: {:case_sensitive => false}

  	belongs_to :organization
	validates :organization, presence: true


	# returns true if there is a service associated with the
	# table on the given date
	def occupied?(date)
		Service.by_date(date, "day").where(table_id: id, status: "incomplete").any?
	end
end
