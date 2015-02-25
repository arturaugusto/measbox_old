class ValuesDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: params[:klass].classify.constantize.count,
      iTotalDisplayRecords: values.total_entries,
      aaData: data
    }
  end

private

  def data
    values.map do |value|
      [
        link_to(value.name, {:action => "edit", :id => value.id}, :class => 'value_chooser_option', :data => {:id => value.id, :name => value.name, :dismiss => 'modal'} ),
        value.created_at.strftime("%B %e, %Y")
      ]
    end
  end

  def values
    @values ||= fetch_values
  end

  def fetch_values
    values = params[:klass].classify.constantize.order("#{sort_column} #{sort_direction}")
    values = values.page(page).per_page(per_page)
    if params[:sSearch].present?
      values = values.where("name like :search", search: "%#{params[:sSearch]}%")
    end
    (values)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end