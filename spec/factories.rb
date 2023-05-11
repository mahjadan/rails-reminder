FactoryBot.define do
  factory :notification do
    due_date { "2023-05-10 19:27:33" }
    reminder { nil }
    user { nil }
    completed_at { "2023-05-10 19:27:33" }
  end

  factory :user do
    
  end

  factory(:reminder) do
    title { Faker::Hobby.activity }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    due_date { Faker::Time.between(from: DateTime.now , to: DateTime.now + 1.hour) }
    repeat_frequency { 'no_repeat' }
  end
end