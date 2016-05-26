FactoryGirl.define do
  factory :service do
    client { FFaker::Name.name }
  	organization
	association :coordinator, factory: :user
	association :administrator, factory: :user, credentials: "administrator"
	representative
	# reservation
	quantity { rand() * 9 + 1 }
	comment { FFaker::Lorem.phrase }
	date DateTime.now
	table
	# ammount { rand() * 100 }
  end

end
