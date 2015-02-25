json.array!(@services) do |service|
  json.extract! service, :order_number, :details
  json.url service_url(service, format: :json)
end