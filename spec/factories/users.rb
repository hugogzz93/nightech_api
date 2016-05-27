FactoryGirl.define do
  factory :user do
  	organization
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "12345678"
    password_confirmation "12345678"
  end

  factory :administrator, class: User do
  	organization
  	credentials "administrator"
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "12345678"
    password_confirmation "12345678"
  end
end
