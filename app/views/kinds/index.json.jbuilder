json.array!(@kinds) do |kind|
  json.extract! kind, :name
  json.url kind_url(kind, format: :json)
end