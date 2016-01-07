class AssetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]
  before_action :set_asset, only: [:show, :edit, :update, :destroy]

  def get_json
    @asset = Asset.find(params[:id])
    # Include some nested
    render :json => @asset, :include => {:model => {:only => :name, :include => [{:kind => {:only => :name} }, {:manufacturer => {:only => :name} }] } }
  end


  # GET /assets
  # GET /assets.json
  def index
    #@assets = Asset.all
    respond_to do |format|
      format.html
      format.json { render json: AssetsDatatable.new(view_context) }
    end    
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
  end

  # GET /assets/new
  def new
    @asset = Asset.new
  end

  # GET /assets/1/edit
  def edit
    @avaliable_ranges = nil
    if not @asset.model.nil? then
      first_model_tag = @asset.model.models[0]
      if first_model_tag != nil then
        @avaliable_ranges = Snippet.tagged_with(first_model_tag.name, :on => :models)
      end
    end

    return @avaliable_ranges
    #@avaliable_ranges = @asset.model.nil? ? nil : Snippet.tagged_with(@asset.model.models[0].name, :on => :models)
    #@ranges = Snippet.tagged_with([params[:tag]], :wild => true, :any => true)
  end

  # POST /assets
  # POST /assets.json
  def create
    @asset = Asset.new(asset_params)

    respond_to do |format|
      if @asset.save
        format.html { redirect_to edit_asset_path(@asset), notice: 'Asset was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @asset }
      else
        format.html { render action: 'new' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assets/1
  # PATCH/PUT /assets/1.json
  def update
    respond_to do |format|
      if @asset.update(asset_params)
        format.html { redirect_to edit_asset_path(@asset), notice: 'Asset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.json
  def destroy
    @asset.destroy
    respond_to do |format|
      format.html { redirect_to assets_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_params
      params.require(:asset).permit(:serial, :company_id, :identification, :certificate, :calibration_date, :due_date, :visa_address, :model_id, :reclassification, :use_reclassification, :avaliable, :calibrated_by)
    end
end
