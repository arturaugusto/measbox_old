class ServicesDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Service.count,
      iTotalDisplayRecords: services.total_entries,
      aaData: data
    }
  end

private

  def data
    services.map do |service|
      [
        link_to(service.order_number, service, :tab => 'service'),
        service.details,
        service.updated_at.strftime("%B %e, %Y")
      ]
    end
  end

  def services
    @services ||= fetch_services
  end

  def fetch_services
    services = Service.order("#{sort_column} #{sort_direction}")
    services = services.page(page).per_page(per_page)
    if params[:sSearch].present?
      services = services.where("order_number like :search", search: "%#{params[:sSearch]}%")
    end
    (services)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[order_number details updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end