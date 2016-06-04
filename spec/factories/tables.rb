FactoryGirl.define do

	sequence :table_number do |n|
	    "#{n}"
  	end
  factory :table do
  	organization
    number { generate(:table_number) }
    x { (rand() * 100 + 1).round }
    y { (rand() * 100 + 1).round }

  end

end
