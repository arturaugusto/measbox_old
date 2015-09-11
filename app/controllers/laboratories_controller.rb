class LaboratoriesController < ApplicationController
  #skip_before_filter :verify_authenticity_token, :only => [:new]
  before_action :role_required, only: [:update, :destroy, :edit, :index, :show]
  before_action :set_laboratory, only: [:edit, :update]

  def show
    @laboratory = Laboratory.find(params[:id])
    #@lab_href = 'http:\\\\' + @laboratory.subdomain + '.' + request.original_url.split('//').last.split('/').first
    @lab_href = 'http:\\\\' + @laboratory.subdomain + '.' + MeasWeb::Application.config.host
  end

  def new

    #if (request.subdomain != '')
    #  redirect_to :controller=> 'my_devise/sessions', :action => 'new'
    #else
      @laboratory = Laboratory.new
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @laboratory }
      end
    #end
  end

  def edit
  end  

  def update
    respond_to do |format|
      if @laboratory.update(laboratory_params)
        format.html { redirect_to edit_laboratory_path(@laboratory), notice: 'Laboratory was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @laboratory.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @laboratory = Laboratory.new(laboratory_params)
    if (verify_recaptcha) or (Rails.env.development?)
      respond_to do |format|
        if @laboratory.save
          # Create a admin role and a technican role
          @inactive_role = Role.new(:laboratory_id => @laboratory.id.to_s, :name => 'inactive', :title => 'Inactive', :description => 'Inactive account', :the_role => { :system => {:administrator => false} } )
          @admin_role = Role.new(:laboratory_id => @laboratory.id.to_s, :name => 'admin', :title => 'Admin role', :description => 'Can manage anything', :the_role => { :system => {:administrator => true} } )
          @technican_role = Role.new(:laboratory_id => @laboratory.id.to_s, :name => 'technican', :title => 'Technician', :description => 'Technican can manage services.', 
            :the_role => 
              { :services => 
                { :index => true, :create => true, :edit => true, :update_unvalidated => false, :update_validated => true, :destroy_unvalidated => true, :destroy_validated => false}, 
              :spreadsheets => 
                { :create => true, :edit => true}, 
              :assets => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :models => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :manufacturers => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :kinds => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :snippets => 
                { :index => true, :create => false, :edit => true, :update_unvalidated => false, :update_validated => false, :destroy_unvalidated => false, :destroy_validated => false}, 
              :users => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :companies => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :roles => 
                { :index => true, :create => false, :edit => false, :update => false, :destroy => false}, 
              :laboratory => 
                { :edit => false, :update => false},
              :system => 
                { :administrator => false}
              })
              
          @report_template = ReportTemplate.new(:laboratory_id => @laboratory.id.to_s, :name => 'Default', :value => 
"
Calibration Certificate
=============================
     
'''
Item
'''
Description              | Model              | Serial  
---------------------------|---------------------|---------
{% for a in uut_assets -%}
{{a.model.kind.name}}    | {{a.model.name}}   | {{a.serial}} 
{%- endfor %}   

'''
Calibration Information
'''
   |    |   |    |
--:|:--|--:|:--|
**Customer Name:**   |   {{ uut_assets[0].company.name }}  | **Certificate Number:** | {{service.information.certificates[0].cert_number}} 
**Address:**                |   {{ uut_assets[0].company.details }} | **Calibration Date:** | {{service.calibration_date|date('M d, Y')}}
**PO Number:**          |   {{service.order_number}}                | **Certificate Date:** | {{ now|date('M d, Y') }}  
**Procedures:**           | {% for p in service.information.procedures -%}{{p.procedure}}, version {{p.version}}{%- endfor %} | **Temperature:** | {{service.information.enviromental_conditions.temperature}} &plusmn; 3 ºC
**Notes:**  | {%- for n in service.information.notes -%} - {{n.note}} <br> {%- endfor -%} | **Relative humidity:**  |  {{service.information.enviromental_conditions.humidity}}  &plusmn; 10 %


**Calibrated By:** {{service.user.title}} {{service.user.name}}  



'''
Assets:
'''
   Description         | Model            | SN           | Certificate       | Due  
:---------------------:|:----------------:|:------------:|:-----------------:|:----:
{% for r in ref_assets -%}
{{r.model.kind.name}}  | {{r.model.name}} | {{r.serial}} | {{r.certificate}} |  {{r.due_date|date('M d, Y')}}
{%- endfor %}



{% for r in cal_ranges -%}
'''
{{ r.end_fmt }} {{ r.last_prefix }}{{ r.unit }}  
$$ {{ r.mpe_TeX }} $$
'''
 UUT | Reference | Error | Admissive Error | Uncertainty | k  | &#120584;<sub>eff</sub>
:---:|:---------:|:-----:|:---------------:|:-----------:|:--:|:--:
{% for p in r.points -%}
{% if p.prefix_transition -%}
**({{p.uut_prefix}}{{p.uut_unit}})** | **({{p.uut_prefix}}{{p.uut_unit}})** | **({{p.uut_prefix}}{{p.uut_unit}})** | **({{p.uut_prefix}}{{p.uut_unit}})** | **({{p.uut_prefix}}{{p.uut_unit}})** | |
{%- endif -%}
{{p.uut_readout_fmt}} | {{p.correct_value_fmt}} | {{p.err_fmt}} | {{p.mpe_fmt}} | {{p.U_fmt}} | {{p.k_fmt}}  | {{p.veff_fmt}}
{%- endfor %}
{% endfor %}
"
          )
          @main_company = Company.new(:laboratory => @laboratory, name: @laboratory.name)
          if (@main_company.save and @admin_role.save and @technican_role.save and @inactive_role.save) and (@report_template.save)
            format.html { redirect_to(controller: 'my_devise/registrations', action: 'new', subdomain: @laboratory.subdomain) }
            #format.json { render action: '/users/sign_up', status: :created, location: @laboratory, :subdomain => @laboratory.subdomain }
          else
            format.html { render action: 'new' }
            format.json { render json: @laboratory.errors, status: :unprocessable_entity }
          end
        else
            format.html { render action: 'new' }
            format.json { render json: @laboratory.errors, status: :unprocessable_entity }          
        end
      end
    else
      flash.now[:error] = "There was an error with the recaptcha code below. Please re-enter the code."      
      flash.delete :recaptcha_error
      render :new
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_laboratory
      @laboratory = Laboratory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def laboratory_params
      params.require(:laboratory).permit(:name, :subdomain, :custom_forms)
    end


end


