json.extract! reminder, :id, :title, :description, :due_date, :repeat_frequency, :created_at, :updated_at
json.url reminder_url(reminder, format: :json)
