module ApplicationHelper
  # Always use the Twitter Bootstrap pagination renderer
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => BootstrapPagination::Rails
    end
    super *[collection_or_options, options].compact
  end
  def raw_template(association)
    fields = render("shared/" + association.to_s.singularize + "_fields")
    content_tag(:hidden, "", id: association.to_s.singularize + "_template", data: {fields: fields.gsub("\n", "")})
  end

  def asset_data_base64(path)
    asset = Rails.application.assets.find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end
end

