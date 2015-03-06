class ReportsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    #respond_to do |format|
    #  format.html { render :text => @report.value }
    #end
  end

  # GET /reports/new
  def new
    @service = Service.find(params[:service_id])
    @report = Report.new(service_id: @service.id)
    respond_to do |format|
      if @report.save
        format.html { redirect_to edit_report_path(@report.id), notice: 'Report was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @report }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render action: 'show', status: :created, location: @report }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    if cant_manage then
      access_denied
    else
      respond_to do |format|
        if @report.update(report_params)
          #format.html { redirect_to edit_report_path(@report), notice: 'Report was successfully updated.' }
          #format.json { head :no_content }
          format.js { render :js=>'console.log("saved!");' }
        else
          format.html { render action: 'edit' }
          format.json { render json: @report.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    if cant_manage then
      access_denied
    else    
      @report.destroy
      respond_to do |format|
        format.html { redirect_to service_url(@report.service, :tab => 'reports') }
        format.json { head :no_content }
      end
    end
  end

  private
    def cant_manage
      @service = @report.service
      if (@service.validated and (not current_user.has_role?(:services, :update_validated))) or ((not @service.validated) and (not current_user.has_role?(:services, :update_unvalidated))) then
        return true
      else
        return false
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:name, :value, :service_id, :laboratory_id, :report_template_id)
    end
end
