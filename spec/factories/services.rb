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

factory :service_given_org, class: Service do
  	organization
    client { FFaker::Name.name }
    coordinator { FactoryGirl.create :user, organization: organization }
    administrator { FactoryGirl.create :administrator, organization: organization }
	representative
	quantity { rand() * 9 + 1 }
	comment { FFaker::Lorem.phrase }
	date DateTime.now
	table { FactoryGirl.create :table, organization: organization }
  end

end
