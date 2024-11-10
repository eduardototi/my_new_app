FactoryBot.define do
  factory :rating do
    association :post
    association :user
    value { [ 1, 2, 3, 4, 5 ].sample }
  end
end
