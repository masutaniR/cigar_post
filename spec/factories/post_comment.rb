FactoryBot.define do
  factory :post_comment do
    comment { Faker::Lorem.characters(number: 20) }
    category { rand(0..2) }
    user
    post
  end
end