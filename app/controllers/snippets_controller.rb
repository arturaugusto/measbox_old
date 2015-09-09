class SnippetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:create, :edit, :index]
  before_action :set_snippet, only: [:show, :edit, :update, :destroy]

  def get_json
    @snippet = Snippet.find(params[:id])
    if params[:model_id] then
      @model = Model.includes(:manufacturer).where(:id => params[:model_id]).first
    else
      @model = {}
    end

    if params[:asset_id] then
      @asset = Asset.find(params[:asset_id])
    else
      @asset = {}
    end

    render json: { snippet: @snippet, tag_list: (@snippet.functionality_list + @snippet.model_list).to_s, model: @model.as_json(:include => :manufacturer), asset: @asset }
  end

  # GET /snippets/autocomplete
  def autocomplete
    if params[:global_snippets].present? and params[:global_snippets] == "true"
      @pre_snippets = Snippet.unscoped.tagged_with([params[:tag]], :wild => true, :any => true) # Find by tag param, allow wildcard
    else
      @pre_snippets = Snippet.tagged_with([params[:tag]], :wild => true, :any => true)
    end
    @snippets = @pre_snippets
    .where(:flavor => params[:flavor]) # set the flavor of snippet (asset or math model)
    .map { |s| ( (params[:skip_model]).nil? ? s.model_list : [] ) + s.functionality_list } # map to arrays
    .reduce(:+) # recude do one array and without duplicate
    #.tagged_with(params[:tags])
    if @snippets then
      render json: @snippets.uniq
    else
      render json: []
    end
  end

  # GET /snippets
  # GET /snippets.json
  def index
    #@snippets = Snippet.all
    respond_to do |format|
      format.html
      format.json { render json: SnippetsDatatable.new(view_context) }
    end

  end

  # GET /snippets/1
  # GET /snippets/1.json
  def show
  end

  # GET /snippets/new
  def new
    if params[:clone].present?
       old_snippet = Snippet.unscoped.find(params[:clone])
       @snippet = old_snippet.dup
    else
      @snippet = Snippet.new
    end
  end

  # GET /snippets/1/edit
  def edit
  end

  # POST /snippets
  # POST /snippets.json
  def create
    @snippet = Snippet.new(snippet_params)

    respond_to do |format|
      if @snippet.save
        format.html { redirect_to edit_snippet_path(@snippet), notice: 'Snippet was successfully created.' }
        format.json { render action: 'show', status: :created, location: @snippet }
      else
        format.html { render action: 'new' }
        format.json { render json: @snippet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /snippets/1
  # PATCH/PUT /snippets/1.json
  def update
    if cant_manage then
      access_denied
    else
      respond_to do |format|
        if @snippet.update(snippet_params)
          format.html { redirect_to edit_snippet_path(@snippet), notice: 'Snippet was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @snippet.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /snippets/1
  # DELETE /snippets/1.json
  def destroy
    if cant_manage then
      access_denied
    else
      @snippet.destroy
      respond_to do |format|
        format.html { redirect_to snippets_url }
        format.json { head :no_content }
      end
    end
  end

  private
    def cant_manage
      # Cant if validated and dont have update_validated role
      if (@snippet.validated and (not current_user.has_role?(:snippets, :update_validated))) or 
      # Cant if is other labs snippet
        (@snippet.laboratory_id != current_user.laboratory_id) or
      # Cant if validated and dont have update_unvalidated role
        ((not @snippet.validated) and (not current_user.has_role?(:snippets, :update_unvalidated))) then
        return true
      else
        return false
      end
    end  

    # Use callbacks to share common setup or constraints between actions.
    def set_snippet
      # USE UNSCOPED TO REMOVE SCOPED AND ACESS OTHER USERS SNIPPETS
      @snippet = Snippet.unscoped.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def snippet_params
      params.require(:snippet).permit(:flavor, :value, :model_list, :functionality_list, :tags, :id, :validated, :model_id)
    end
end
