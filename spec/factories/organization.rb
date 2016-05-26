FactoryGirl.define do
	factory :organization do
		name { FFaker::Company.name }
		active true
	end
end