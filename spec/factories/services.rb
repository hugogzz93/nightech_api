FactoryGirl.define do
  factory :service do
    client { FFaker::Name.name }
	association :coordinator, factory: :user
	association :administrator, factory: :administrator
  	organization { administrator.organization }
	representative
	quantity { rand() * 9 + 1 }
	comment { FFaker::Lorem.phrase }
	date DateTime.now
	table
  end

end
