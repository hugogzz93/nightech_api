FactoryGirl.define do
  factory :representative do
    name { FFaker::Name.name }
	user
  end

end
