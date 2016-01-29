FactoryGirl.define do
  factory :service do
    client { FFaker::Name.name }
	user
	administrator
	representative
	reservation
	quantity { rand() * 9 + 1 }
	comment { FFaker::Lorem.phrase }
	date "2016-01-27 12:41:01"
	# ammount { rand() * 100 }
  end

end
