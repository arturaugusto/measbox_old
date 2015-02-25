json.array!(@reports) do |report|
  json.extract! report, :name, :value, :service_id, :laboratory_id
  json.url report_url(report, format: :json)
end