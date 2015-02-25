json.array!(@models) do |model|
  json.extract! model, :name, :manufacturer_id, :kind_id
  json.url model_url(model, format: :json)
end