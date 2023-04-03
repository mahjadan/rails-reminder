# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

puts "Sedding data"
Reminder.destroy_all

5.times do
    Reminder.create(
        title: Faker::Hobby.activity,
        description: Faker::Lorem.paragraph(sentence_count: 2),
        due_date: Faker::Time.between(from: DateTime.now , to: DateTime.now + 1.hour),
        repeat_frequency: 'no_repeat'
    )
end