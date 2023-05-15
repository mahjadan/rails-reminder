FactoryBot.define do
  factory :notification do
    scheduled_at { DateTime.now + 1.day }
    association :reminder
    association :user
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
  end

  factory(:reminder) do
    title { Faker::Hobby.activity }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    due_date { Faker::Time.between(from: DateTime.now + 1.minute , to: DateTime.now + 1.hour) }
    repeat_frequency { 'no_repeat' }
    association :user
  end
end