FactoryBot.define do
  factory :information do
    title { Faker::Lorem.characters(number: 20) }
    body { Faker::Lorem.characters(number: 500) }
  end
end