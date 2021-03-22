FactoryBot.define do
  factory :post do
    body { Faker::Lorem.characters(number:30) }
    category { rand(0..2) }
    user
  end
end