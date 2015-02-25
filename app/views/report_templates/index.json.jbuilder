json.array!(@report_templates) do |report_template|
  json.extract! report_template, :laboratory_id, :name, :value
  json.url report_template_url(report_template, format: :json)
end