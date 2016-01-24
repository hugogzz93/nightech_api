FactoryGirl.define do
  factory :reservation do
    client { FFaker::Name.name }
	user
	representative
	quantity { rand() * 9 + 1 }
	comment { FFaker::Lorem.phrase }
	date "2016-01-23 23:17:06"
	# status 0
	# visible false
  end

end
