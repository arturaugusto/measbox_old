class LaboratoriesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:new]
  before_action :role_required, only: [:update, :destroy, :edit, :index]
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
          @inactive_role = Role.new(:laboratory_id => @laboratory, :name => 'inactive', :title => 'Inactive', :description => 'Inactive account', :the_role => { :system => {:administrator => false} } )
          @admin_role = Role.new(:laboratory_id => @laboratory, :name => 'admin', :title => 'Admin role', :description => 'Can manage anything', :the_role => { :system => {:administrator => true} } )
          @technican_role = Role.new(:laboratory_id => @laboratory, :name => 'technican', :title => 'Technician', :description => 'Technican can manage services.', 
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
              
          @report_template = ReportTemplate.new(:laboratory_id => @laboratory, :name => 'Default', :value => 
'
<div style="text-align: center;"><span style="font-size: 22px;">Cert. No. {{service.information.certificates[0].cert_number}}</span></div>
<span style="font-size: 14px;">
<table width="100%">
  <tbody>
    <tr>
      <td><span style="font-size: 14px;"><strong>Customer:</strong></span></td>

      <td><span style="font-size: 14px;">&nbsp;{{ uut_assets[0].company.name }}</span></td>
    </tr>

    <tr>
      <td></td>

      <td><span style="font-size: 14px;">&nbsp;{{ uut_assets[0].company.details }}</span></td>
    </tr>
  </tbody>
</table>
</span><b>Item:&nbsp;</b><br>
{% filter wrap_table %}{% for a in uut_assets %}<br>

<table>
  <tbody>
    <tr>
      <th>Description</th>

      <th>Model</th>

      <th>Serial</th>
    </tr>

    <tr>
      <td>{{a.model.kind.name}}</td>

      <td>{{a.model.name}}</td>

      <td>{{a.serial}}</td>
    </tr>
  </tbody>
</table>
{% endfor&nbsp;%}{% endfilter&nbsp;%}<b>Calibration Information:</b>
<table width="100%">
  <tbody>
    <tr>
      <td><strong>Calibration Date:</strong></td>

      <td>{{service.calibration_date}}</td>
    </tr>

    <tr>
      <td><strong>Calibrated By:</strong></td>

      <td>{{service.user.title}}&nbsp;{{service.user.name}}</td>
    </tr>

    <tr>
      <td><strong>Procedures:</strong></td>

      <td>{% for p in service.information.procedures %}{% if loop.last %} and {% endif %}{{p.procedure}}{% if not loop.last %}, {% endif %}{% endfor %}.</td>
    </tr>

    <tr>
      <td><strong>Enviromental:</strong></td>

      <td>{{service.information.enviromental_conditions.temperature}},&nbsp;{{service.information.enviromental_conditions.humidity}}</td>
    </tr>
  </tbody>
</table>
<b>Purchase order:&nbsp;</b>{{service.order_number}}<br>
<b>Notes:</b>&nbsp;<br>
{% for n in service.information.notes %}{{n.note}}{% if not loop.last %}&lt;br&gt;{% endif %}{% endfor %}<br>
<b>Certificate Date:</b>&nbsp;{{ now|date(\'Y-m-d\')&nbsp;}}<b><br>
         Assets</b><br>
{% filter wrap_table %}{% for a in ref_assets %}<br>

<table>
  <tbody>
    <tr>
      <th style="text-align: center;">Descricao</th>

      <th style="text-align: center;">Modelo</th>

      <th style="text-align: center;">Numero de serie</th>

      <th style="text-align: center;">Certificado</th>

      <th style="text-align: center;">Validade</th>
    </tr>

    <tr>
      <td style="text-align: center;">{{a.model.kind.name}}</td>

      <td style="text-align: center;">{{a.model.name}}</td>

      <td style="text-align: center;">{{a.serial}}</td>

      <td style="text-align: center;">{{a.certificate}}</td>

      <td style="text-align: center;">{{a.due_date|date(\'M./Y\')}}</td>
    </tr>
  </tbody>
</table>
{% endfor %}{% endfilter %}<br>
<b>Results</b><br>
<b></b>{% for s in spreadsheets %}{{s.description}}{% filter wrap_table %}{% for t in s.table_json.table_data %}
<table>
  <tbody>
    <tr>
      <th style="text-align: center;">UUT<br>
         ({{t._prefix}}<span style="-webkit-text-stroke-width: 0px; background-color: rgb(230, 230, 230); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t._unit}})</span></th>

      <th style="text-align: center;">Reference<br>
         ({{t._prefix}}<span style="-webkit-text-stroke-width: 0px; background-color: rgb(230, 230, 230); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t._unit}})</span></th>

      <th style="text-align: center;">Error<br>
<span style="-webkit-text-stroke-width: 0px; background-color: rgb(230, 230, 230); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">({{t._prefix}}<span style="box-sizing: content-box;">{{t._unit}})</span></span></th>

      <th style="text-align: center;">Admissive Error<br>
<span style="-webkit-text-stroke-width: 0px; background-color: rgb(230, 230, 230); box-sizing: content-box; color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">({{t._prefix}}{{t._unit}})</span></th>

      <th style="text-align: center;">Uncertainty<br>
<span style="-webkit-text-stroke-width: 0px; background-color: rgb(230, 230, 230); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">({{t._prefix}}{{t._unit}})</span></th>

      <th style="text-align: center;">k<br>
<br>
      </th>

      <th style="text-align: center;"><span style="font-size: 17px;">&#120526;</span><br>
<br>
      </th>
    </tr>

    <tr>
      <td style="text-align: center;">{{t.UUT}}</td>

      <td style="text-align: center;">{{t.Reference}}</td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.e}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.MPE}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.U}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.k}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.veff}}</span><br>
      </td>
    </tr>
  </tbody>
</table>
{%&nbsp;endfor %}{%&nbsp;endfilter %}{%&nbsp;endfor %}
'
          )
          @main_company = Company.new(:laboratory => @laboratory, name: @laboratory.name)
          if (@main_company.save and @admin_role.save and @technican_role.save and @inactive_role.save) and (@report_template.save)
            format.html { redirect_to @laboratory, notice: 'Laboratory was successfully created.' }
            format.json { render action: 'show', status: :created, location: @laboratory }
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


