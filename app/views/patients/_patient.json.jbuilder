json.extract! patient, :id, :first_name, :middle_initial, :last_name, :phone, :email, :approver, :location, :created_at, :updated_at
json.url patient_url(patient, format: :json)
