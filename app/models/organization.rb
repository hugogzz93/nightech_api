class Organization < ActiveRecord::Base
	
	has_many :users, dependent: :destroy
	has_many :services, dependent: :destroy
	has_many :reservations, dependent: :destroy
	has_many :representatives, dependent: :destroy
	has_many :tables, dependent: :destroy

	validates :name, presence: true, uniqueness: true


end
