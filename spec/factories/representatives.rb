FactoryGirl.define do
  factory :representative do
    name { FFaker::Name.name }
	user
  	organization
  end

end
