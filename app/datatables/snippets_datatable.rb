class SnippetsDatatable
  delegate :params, :h, :link_to, :edit_snippet_path, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Snippet.count,
      iTotalDisplayRecords: snippets.total_entries,
      aaData: data
    }
  end

private

  def data
    snippets.map do |snippet|
      
      if snippet.flavor == 1 then
        link_text = "Instrument"
        link_class = "asset_snippet_chooser"
      else
        link_text = "Procedure"
        link_class = "math_snippet_chooser"
       end
      [
        link_to( link_text, edit_snippet_path(snippet), :tab => 'snippet', :class => link_class, :s_id => snippet.id),
        snippet.updated_at.strftime("%B %e, %Y"),
        (snippet.model_list + snippet.functionality_list).uniq
      ]
    end
  end

  def snippets
    @snippets ||= fetch_snippets
  end

  def fetch_snippets
    # Check If searching for all snippets
    if params[:global_snippets].present? and params[:global_snippets] == "true"
      snippets = Snippet.unscoped.order("#{sort_column} #{sort_direction}")
    else
      snippets = Snippet.order("#{sort_column} #{sort_direction}")
    end
    snippets = snippets.page(page).per_page(per_page)
    if params[:flavor].present?
      snippets = snippets.where(:flavor => params[:flavor])
    end
    pre_tags = []
    if params[:pre_tags].present?
      pre_tags = params[:pre_tags].split(" ")
    end


    if params[:sSearch].present?
      
      # Here, a bug can happends
      # see: https://github.com/mbleigh/acts-as-taggable-on/pull/496
      if params[:func_tag_list].present?
        func_tag_list = []
        func_tag_list = params[:func_tag_list].split(" ")
        snippets = snippets.tagged_with([params[:sSearch]] + pre_tags, :on => :models).tagged_with(func_tag_list, :on => :functionalities, :any => true)
      else
        snippets = snippets.tagged_with([params[:sSearch]] + pre_tags)
      end
    end
    (snippets)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[flavor updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end