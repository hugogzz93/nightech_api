class Organization < ActiveRecord::Base
	
	has_many :users, dependent: :destroy
	has_many :services, dependent: :destroy
	has_many :reservations, dependent: :destroy
	has_many :representatives, dependent: :destroy
	has_many :tables, dependent: :destroy

	validates :name, :map, presence: true, uniqueness: true
	validate :map_regex

	def map_regex
		unless map && map.match('^M \d+(\.?\d+)?,\d+(\.\d+)?(\s[MNL] \d+(\.?\d+)?,\d+(\.\d+)?)*$')
			errors.add(:map, "Map does not contain valid string.")
		end
	end
end
