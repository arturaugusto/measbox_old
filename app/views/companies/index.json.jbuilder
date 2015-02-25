json.array!(@companies) do |company|
  json.extract! company, :name, :address, :details
  json.url company_url(company, format: :json)
end