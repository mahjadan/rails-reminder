FactoryBot.define do
  factory(:reminder) do
    title { Faker::Hobby.activity }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    due_date { Faker::Time.between(from: DateTime.now , to: DateTime.now + 1.hour) }
    repeat_frequency { 'no_repeat' }
  end
end