json.array!(@snippets) do |snippet|
  json.extract! snippet, 
  json.url snippet_url(snippet, format: :json)
end