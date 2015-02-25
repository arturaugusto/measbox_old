class SpreadsheetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:create, :edit, :index]
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy, :cant_manage]

  def autocomplete
    render json: Snippet.find(:flavor => 1).tagged_with(params[:tags])
  end

  # GET /spreadsheets
  # GET /spreadsheets.json
  def index
    @spreadsheets = Spreadsheet.all
  end

  # GET /spreadsheets/1
  # GET /spreadsheets/1.json
  def show
  end

  def sort
    params[:spreadsheets].each_with_index do |id, index|
      Spreadsheet.where("id = ?", id).update_all(position: index + 1)
    end    
    render nothing: true
  end

  # GET /spreadsheets/new
  def new
    @service = Service.find(params[:service_id])
    @spreadsheet = Spreadsheet.new(service_id: @service.id)
    respond_to do |format|
      if @spreadsheet.save
        format.html { redirect_to edit_spreadsheet_path(@spreadsheet.id), notice: 'Spreadsheet was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @spreadsheet }
      else
        format.html { render action: 'new' }
        format.json { render json: @spreadsheet.errors, status: :unprocessable_entity }
      end
    end

    #@spreadsheet = Spreadsheet.new
    #@spreadsheet = Spreadsheet.new(service_id: params[:service_id])

    #@spreadsheet = Spreadsheet.find_or_create_by(service_id: params[:service_id])
  end

  # GET /spreadsheets/1/edit
  def edit
    @service = @spreadsheet.service 
    @assets = @spreadsheet.service.assets

    @model_lookup = @spreadsheet.service.assets.map { |a| [{'model' => a.model, 'asset_id' => a.id}] }

    #@snippets = Snippet.tagged_with(model_lookup, :wild => false, :any => true) # Find by tag param
    #.where(:flavor => 1) # set the flavor of snippet to asset 
  end

  # POST /spreadsheets
  # POST /spreadsheets.json
  def create
    @spreadsheet = Spreadsheet.new(spreadsheet_params)
    respond_to do |format|
      if @spreadsheet.save
        format.html { redirect_to @spreadsheet, notice: 'Spreadsheet was successfully created.' }
        format.json { render action: 'show', status: :created, location: @spreadsheet }
      else
        format.html { render action: 'new' }
        format.json { render json: @spreadsheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /spreadsheets/1
  # PATCH/PUT /spreadsheets/1.json
  def update
    if cant_manage then
      access_denied
    else
      respond_to do |format|
        if @spreadsheet.update(spreadsheet_params)
          #format.html { redirect_to edit_spreadsheet_path(@spreadsheet), notice: 'Spreadsheet was successfully updated.' }
          #format.json { head :no_content }
          format.js { render :js=>'console.log("saved!");' }
        else
          format.html { render action: 'edit' }
          format.json { render json: @spreadsheet.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /spreadsheets/1
  # DELETE /spreadsheets/1.json
  def destroy
    if cant_manage then
      access_denied
    else    
      @spreadsheet.destroy
      respond_to do |format|
        format.html { redirect_to service_url(@spreadsheet.service, :tab => 'spreadsheets') }
        format.json { head :no_content }
      end
    end
  end

  private
    def cant_manage
      @service = @spreadsheet.service
      if (@service.validated and (not current_user.has_role?(:services, :update_validated))) or ((not @service.validated) and (not current_user.has_role?(:services, :update_unvalidated))) then
        return true
      else
        return false
      end
    end  
    # Use callbacks to share common setup or constraints between actions.
    def set_spreadsheet
      @spreadsheet = Spreadsheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def spreadsheet_params
      params.require(:spreadsheet).permit(:id, :description, :mathematical_model, :table_json, :service_id, :position, :tag_list)
    end
end
