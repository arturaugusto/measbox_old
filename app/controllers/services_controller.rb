class ServicesController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:create, :edit, :index]
  after_action :reorder, only: [:update, :create]
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  def reorder
    # remove blank
    if not @service.new_record?
      assets = service_params[:asset_ids].reject! { |c| c.empty? }
      positions = params[:asset_positions]
      # Keep order if items
      assets.each_with_index do |asset, i|
        wb = @service.workbenches.where(:asset_id => asset).first
        wb.insert_at(positions[i].to_i(10))
      end
    end    
  end

  # GET /services
  # GET /services.json
  def index
    #@services = Service.all
    respond_to do |format|
      format.html
      format.json { render json: ServicesDatatable.new(view_context) }
    end
  end

  # GET /services/1
  # GET /services/1.json
  def show
    @spreadsheets = @service.spreadsheets.order("position")
    @assets = @service.assets
    @reports = @service.reports
    @details_lines = @service.details.split("\n")
    respond_to do |format|
      format.html
      format.json { 
        render :json => {
          :laboratory => current_laboratory.as_json(),
          :service => @service.as_json(:include => :user),
          :spreadsheets => @spreadsheets,
          :assets => @assets.as_json(
            :include => 
            [
              :company,
              {
                :model => {
                  :only => :name, 
                  :include => 
                  [
                    {:kind => {:only => :name} },
                    {:manufacturer => {:only => :name} }
                  ]
                }
              }
            ]
          )
        }
      }
    end    
  end

  # GET /services/new
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  # POST /services.json
  def create
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: 'Service was successfully created.' }
        format.json { render action: 'show', status: :created, location: @service }
      else
        format.html { render action: 'new' }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json
  def update
    if cant_manage then
      access_denied
    else
      respond_to do |format|
        if @service.update(service_params)
          format.html { redirect_to service_path(@service, :tab => 'spreadsheets'), notice: 'Service was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @service.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    if cant_manage then
      access_denied
    else  
      @service.destroy
      respond_to do |format|
        format.html { redirect_to services_url }
        format.json { head :no_content }
      end
    end
  end

  private
    def cant_manage
      if (@service.validated and (not current_user.has_role?(:services, :update_validated))) or ((not @service.validated) and (not current_user.has_role?(:services, :update_unvalidated))) then
        return true
      else
        return false
      end
    end  
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:order_number, :details, :asset_id, :information, :user_id, :calibration_date, :validated, {:positions => []}, {:asset_ids => []})
    end
end
