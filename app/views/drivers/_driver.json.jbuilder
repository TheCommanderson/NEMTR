json.extract! driver, :id, :first_name, :middle_initial, :last_name, :phone, :email, :approver, :car_make, :car_model, :car_plate, :car_year, :trained, :created_at, :updated_at
json.url driver_url(driver, format: :json)
