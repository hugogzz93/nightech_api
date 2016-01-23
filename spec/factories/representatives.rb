FactoryGirl.define do
  factory :representative do
    name { FFaker::Name.name }
	user_id "3"
  end

end
