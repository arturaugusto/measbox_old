json.extract! @laboratory, :name, :subdomain, :created_at, :updated_at, :custom_forms if current_user
