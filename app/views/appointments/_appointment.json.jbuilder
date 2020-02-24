json.extract! appointment, :id, :patient, :driver, :date_time, :location, :status, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
