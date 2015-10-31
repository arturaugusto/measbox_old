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
    @laboratory.custom_forms = '{"services":"{\n  \"type\": \"object\",\n  \"title\": \"Calibration Information\",\n  \"properties\": {\n    \"certificates\": {\n      \"type\": \"array\",\n      \"options\": {\n        \"collapsed\": true\n      },\n      \"title\": \"Certificates\",\n      \"format\": \"table\",\n      \"uniqueItems\": true,\n      \"items\": {\n        \"type\": \"object\",\n        \"title\": \"Certificate\",\n        \"properties\": {\n          \"cert_number\": {\n            \"title\": \"Number\",\n            \"type\": \"string\"\n          },\n          \"description\": {\n            \"title\": \"Description\",\n            \"type\": \"string\"\n          }\n        }\n      }\n    },\n    \"enviromental_conditions\": {\n      \"type\": \"object\",\n      \"title\": \"Enviromental\",\n      \"properties\": {\n        \"temperature\": {\n          \"type\": \"string\",\n          \"title\": \"Temperature\"\n        },\n        \"humidity\": {\n          \"title\": \"Humidity\",\n          \"type\": \"string\"\n        },\n        \"pressure\": {\n          \"title\": \"Pressure\",\n          \"type\": \"string\"\n        }\n      },\n      \"options\": {\n        \"collapsed\": \"undefined\"\n      }\n    },\n    \"notes\": {\n      \"type\": \"array\",\n      \"options\": {\n        \"collapsed\": true\n      },\n      \"title\": \"Notes\",\n      \"uniqueItems\": true,\n      \"items\": {\n        \"type\": \"object\",\n        \"title\": \"Note\",\n        \"properties\": {\n          \"note\": {\n            \"title\": \"Note\",\n            \"type\": \"string\",\n            \"format\": \"textarea\"\n          }\n        }\n      }\n    },\n    \"procedures\": {\n      \"type\": \"array\",\n      \"title\": \"Procedures\",\n      \"uniqueItems\": true,\n      \"items\": {\n        \"type\": \"object\",\n        \"title\": \"Procedure\",\n        \"properties\": {\n          \"procedure\": {\n            \"title\": \"Procedure\",\n            \"type\": \"string\",\n            \"enum\": [\n              \"aa\",\n              \"bb\"\n            ]\n          }\n        }\n      },\n      \"options\": {\n        \"collapsed\": true\n      }\n    }\n  }\n}","styles":"\n/**\n * Remove most spacing between table cells.\n */\n\ntable {\n    border-collapse: collapse;\n    border-spacing: 0;\n}\n\n\n/* Github css */\n\nhtml,body {\n    max-width: 44em;\n    color: black;\n}\nbody {\n    font: 13.34px helvetica,arial,freesans,clean,sans-serif;\n    -webkit-font-smoothing: subpixel-antialiased;\n    line-height: 1.4;\n    padding: 3px;\n    background: #fff;\n    border-radius: 3px;\n    -moz-border-radius: 3px;\n    -webkit-border-radius: 3px}\np {\n    margin: 1em 0}\na {\n    color: #4183c4;\n    text-decoration: none}\nbody {\n    background-color: #fff;\n    padding: 30px;\n    margin: 15px;\n    font-size: 14px;\n    line-height: 1.6}\nh1 {\n    font-size: 28px;\n    color: #000}\nh2 {\n    font-size: 24px;\n    border-bottom: 1px solid #ccc;\n    color: #000}\nh3 {\n    font-size: 18px;\n    color: #333}\nh4 {\n    font-size: 16px;\n    color: #333}\nh5 {\n    font-size: 14px;\n    color: #333}\nh6 {\n    color: #777;\n    font-size: 14px}\np,blockquote,table,pre {\n    margin: 15px 0}\nul {\n    padding-left: 30px}\nol {\n    padding-left: 30px}\nol li ul: first-of-type {\n    margin-top: 0}\nh1+p,h2+p,h3+p,h4+p,h5+p,h6+p,ul li\u003e:first-child,ol li\u003e:first-child {\n    margin-top: 0}\ntable {\n    border-collapse: collapse;\n    border-spacing: 0;\n    font-size: 100%;\n    font: inherit}\ntable th {\n    font-weight: bold;\n    border: 1px solid #ccc;\n    padding: 6px 13px}\ntable td {\n    border: 1px solid #ccc;\n    padding: 6px 13px}\ntable tr {\n    border-top: 1px solid #ccc;\n    border-left: 0;\n    border-right: 0;\n    border-bottom: 0;\n    background-color: #fff}\ntable tr:nth-child(2n) {\n    background-color: #f8f8f8}\nimg {\n    max-width: 100%}"}' 
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
              
          # I wish using this: &#120584;<sub>eff</sub> as nu symbol get working...
          @report_template = ReportTemplate.new(:laboratory_id => @laboratory.id.to_s, 
            :name => 'Default', 
            :pdf_options => {"orientation"=>"Portrait", "page_size"=>"A4", "margin"=>{"top"=>10, "bottom"=>10, "left"=>10, "right"=>10}, "header"=>{"left"=>"", "center"=>"", "right"=>"Cert. n{{certificates[0].cert_number}}", "spacing"=>0, "font_name"=>"Helvetica", "font_size"=>12}, "footer"=>{"left"=>"", "center"=>"[page]/[toPage]", "right"=>"", "spacing"=>0, "font_name"=>"Helvetica", "font_size"=>12}},
            :value => 
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

<table>
<caption>Calibration Information</caption>
<tbody>
<tr>
<td style='text-align:right'><strong>Customer Name:</strong></td>
<td style='text-align:left'>{{ uut_assets[0].company.name }}</td>
<td style='text-align:right'><strong>Certificate Number:</strong></td>
<td style='text-align:left'>{{service.information.certificates[0].cert_number}} </td>
</tr>
<tr>
<td style='text-align:right'><strong>Address:</strong></td>
<td style='text-align:left'>{{ uut_assets[0].company.details }}</td>
<td style='text-align:right'><strong>Calibration Date:</strong></td>
<td style='text-align:left'>{{service.calibration_date|date('M d, Y')}}</td>
</tr>
<tr>
<td style='text-align:right'><strong>PO Number:</strong></td>
<td style='text-align:left'>{{service.order_number}}</td>
<td style='text-align:right'><strong>Certificate Date:</strong></td>
<td style='text-align:left'>{{ now|date('M d, Y') }}  </td>
</tr>
<tr>
<td style='text-align:right'><strong>Procedures:</strong></td>
<td style='text-align:left'>{{p.procedure}}, version {{p.version}}</td>
<td style='text-align:right'><strong>Temperature:</strong></td>
<td style='text-align:left'>{{service.information.enviromental_conditions.temperature}} ± 3 ºC</td>
</tr>
<tr>
<td style='text-align:right'><strong>Notes:</strong></td>
<td style='text-align:left'>- {{n.note}} <br></td>
<td style='text-align:right'><strong>Relative humidity:</strong></td>
<td style='text-align:left'>{{service.information.enviromental_conditions.humidity}}  ± 10 %</td>
</tr>
</tbody>
</table>

**Calibrated By:** {{service.user.title}} {{service.user.name}}  



'''
Assets:
'''
   Description         | Model            | SN           | Certificate    | Calibrated By   | Due  
:---------------------:|:----------------:|:------------:|:-----------------:|:----:
{% for r in ref_assets -%}
{{r.model.kind.name}}  | {{r.model.name}} | {{r.serial}} | {{r.certificate}} | {{r.calibrated_by}}  | {{r.due_date|date('M d, Y')}}
{%- endfor %}



{% for r in cal_ranges -%}
'''
{{ r.end_fmt }} {{ r.last_prefix }}{{ r.unit }}  
$$ {{ r.mpe_TeX }} $$
'''
 UUT | Reference | Error | Admissive Error | Uncertainty | k  | <i>v</i><sub>eff</sub>
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


