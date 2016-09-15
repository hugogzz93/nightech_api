FactoryGirl.define do
	factory :organization do
		name { FFaker::Company.name }
		map "M 0,0 L 0,0 L 0,0 M 0,0 L 0,0 L 0,0 L 0,0"
		active true
	end
end