FactoryGirl.define do
  factory :user do
  	organization
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "12345678"
    password_confirmation "12345678"
  end

  factory :super, class: User do
    organization
    credentials "super"
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

  factory :coordinator, class: User do
    organization
    credentials "coordinator"
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "12345678"
    password_confirmation "12345678"
  end

  factory :coordinator_given_org, class: User do
    organization
    supervisor { FactoryGirl.create :administrator, organization: organization }
    credentials "coordinator"
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "12345678"
    password_confirmation "12345678"
  end

end
