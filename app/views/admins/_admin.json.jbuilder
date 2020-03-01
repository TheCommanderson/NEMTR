json.extract! admin, :id, :first_name, :middle_init, :last_name, :phone, :email, :auth_lvl, :host_org, :created_at, :updated_at
json.url admin_url(admin, format: :json)
