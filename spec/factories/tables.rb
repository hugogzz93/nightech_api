FactoryGirl.define do

	sequence :table_number do |n|
	    "#{n}"
  	end
  factory :table do
  	organization
    number { generate(:table_number) }
  end

end
