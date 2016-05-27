FactoryGirl.define do
  factory :reservation do
    client { FFaker::Name.name }
	user
  	organization { user.organization }
	representative
	quantity { rand() * 9 + 1 } # 1-10
	comment { FFaker::Lorem.phrase }
	date DateTime.now
	# status 0
	# visible false
  end

end
