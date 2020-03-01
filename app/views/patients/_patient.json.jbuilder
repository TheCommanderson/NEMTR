json.extract! patient, :id, :first_name, :middle_initial, :last_name, :phone, :email, :admin_id, :created_at, :updated_at
json.url patient_url(patient, format: :json)
