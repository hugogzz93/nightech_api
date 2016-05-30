FactoryGirl.define do
  factory :representative do
    name { FFaker::Name.name }
	user
  	organization { user.organization }
  end

end
