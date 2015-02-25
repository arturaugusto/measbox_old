json.array!(@assets) do |asset|
  json.extract! asset, :serial, :company, :identification, :certificate, :calibration_date, :due_date, :visa_address
  json.url asset_url(asset, format: :json)
end