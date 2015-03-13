class ReportTemplatesController < ApplicationController
  before_filter :authenticate_user!  
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]
  before_action :set_report_template, only: [:show, :edit, :update, :destroy]

  def get_json
    @report_template = ReportTemplate.find(params[:id])
    render json: @report_template
  end

  # GET /report_templates
  # GET /report_templates.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ValuesDatatable.new(view_context) }
    end
  end

  # GET /report_templates/1
  # GET /report_templates/1.json
  def show
  end

  # GET /report_templates/new
  def new
    @report_template = ReportTemplate.new
  end

  # GET /report_templates/1/edit
  def edit
  end

  # POST /report_templates
  # POST /report_templates.json
  def create
    @report_template = ReportTemplate.new(report_template_params)

    respond_to do |format|
      if @report_template.save
        format.html { redirect_to edit_report_template_path(@report_template), notice: 'Report template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @report_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @report_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /report_templates/1
  # PATCH/PUT /report_templates/1.json
  def update
    respond_to do |format|
      if @report_template.update(report_template_params)
        format.html { redirect_to edit_report_template_path(@report_template), notice: 'Report template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @report_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_templates/1
  # DELETE /report_templates/1.json
  def destroy
    @report_template.destroy
    respond_to do |format|
      format.html { redirect_to report_templates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report_template
      @report_template = ReportTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_template_params
      params.require(:report_template).permit(:laboratory_id, :name, :value, :pdf_options)
    end
end
