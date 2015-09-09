class AssetsDatatable
  delegate :params, :h, :link_to, :edit_asset_path, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Asset.count,
      iTotalDisplayRecords: assets.total_entries,
      aaData: data
    }
  end

private

  def data
    assets.map do |asset|
      [
        link_to( (asset.identification.nil? or asset.identification.length == 0) ? "Undentified" : asset.identification, edit_asset_path(asset), :tab => 'asset', :class => 'add_asset_fields', :data => {:id => asset.id } ),
        asset.serial,
        asset.certificate,
        asset.calibration_date.nil? ? "" : asset.calibration_date.strftime("%B %e, %Y"),
        asset.due_date.nil? ? "" : asset.due_date.strftime("%B %e, %Y"),
        asset.model.nil? ? "" : asset.model.name
      ]
    end
  end

  def assets
    @assets ||= fetch_assets
  end

  def fetch_assets
    assets = Asset.order("#{sort_column} #{sort_direction}")
    assets = assets.page(page).per_page(per_page)
    if params[:flavor].present?
      assets = assets.where(:flavor => params[:flavor])
    end
    if params[:sSearch].present?

      models = Model.where("name like :search", search: "%#{params[:sSearch]}%")
      model_sql = ""
      models.each do |model|
        model_sql << " or model_id = '" << model.id.to_s() + "'"
      end

      #kinds = Kind.where("name like :search", search: "%#{params[:sSearch]}%")
      #kind_sql = ""
      #kinds.each do |kind|
      #  kind_sql << " or kind_id = '" << kind.id.to_s() + "'"
      #end

      assets = assets.where("identification like :search or serial like :search or certificate like :search" << model_sql , search: "%#{params[:sSearch]}%" )
    end
    (assets)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[identification serial certificate calibration_date due_date]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end