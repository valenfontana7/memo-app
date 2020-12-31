FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { "user" }
    status { "active" }
    email { Faker::Internet.email }
    auth_token { "xxxxx" }
  end
end
