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
      <td><strong>Customer:</strong></td>

      <td>&nbsp;{{ uut_assets[0].company.name }}</td>
    </tr>

    <tr>
      <td></td>

      <td>&nbsp;{{ uut_assets[0].company.details }}</td>
    </tr>
  </tbody>
</table>
<b>Item:&nbsp;</b><br>
</span>
<table wrap_code_open="{% filter wrap_table %}{% for a in uut_assets %}" wrap_code_close="{% endfor %}{% endfilter %}">
  <tbody>
    <tr>
      <th><span style="font-size: 14px;">Description</span></th>

      <th><span style="font-size: 14px;">Model</span></th>

      <th><span style="font-size: 14px;">Serial</span></th>
    </tr>

    <tr>
      <td><span style="font-size: 14px;">{{a.model.kind.name}}</span></td>

      <td><span style="font-size: 14px;">{{a.model.name}}</span></td>

      <td><span style="font-size: 14px;">{{a.serial}}</span></td>
    </tr>
  </tbody>
</table>
<b><span style="font-size: 14px;">Calibration Information:</span></b>
<table width="100%">
  <tbody>
    <tr>
      <td><strong><span style="font-size: 14px;">Calibration Date:</span></strong></td>

      <td><span style="font-size: 14px;">{{service.calibration_date}}</span></td>
    </tr>

    <tr>
      <td><strong><span style="font-size: 14px;">Calibrated By:</span></strong></td>

      <td><span style="font-size: 14px;">{{service.user.title}}&nbsp;{{service.user.name}}</span></td>
    </tr>

    <tr>
      <td><strong><span style="font-size: 14px;">Procedures:</span></strong></td>

      <td><span style="font-size: 14px;">{% for p in service.information.procedures %}{% if loop.last %} and {% endif %}{{p.procedure}}{% if not loop.last %}, {% endif %}{% endfor %}.</span></td>
    </tr>

    <tr>
      <td><strong><span style="font-size: 14px;">Enviromental:</span></strong></td>

      <td><span style="font-size: 14px;">{{service.information.enviromental_conditions.temperature}},&nbsp;{{service.information.enviromental_conditions.humidity}}</span></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px;"><b>Purchase order:&nbsp;</b>{{service.order_number}}<br>
<br>
<b>Notes:</b>&nbsp;<br>
                         {% for n in service.information.notes %}{{n.note}}{% if not loop.last %}&lt;br&gt;{% endif %}{% endfor %}<br>
<b>Certificate Date:</b>&nbsp;{{ now|date(\'Y-m-d\')&nbsp;}}<b><br>
</b><br>
<b>Assets:</b><br>
</span>
<table wrap_code_open="{% filter wrap_table %}{% for a in ref_assets %}" wrap_code_close="{% endfor %}{% endfilter %}" wrap_caption="">
  <tbody>
    <tr>
      <th style="text-align: center;"><span style="font-size: 14px;">Description</span></th>

      <th style="text-align: center;"><span style="font-size: 14px;">Model</span></th>

      <th style="text-align: center;"><span style="font-size: 14px;">SN</span></th>

      <th style="text-align: center;"><span style="font-size: 14px;">Certificate</span></th>

      <th style="text-align: center;"><span style="font-size: 14px;">Due</span></th>
    </tr>

    <tr>
      <td style="text-align: center;"><span style="font-size: 14px;">{{a.model.kind.name}}</span></td>

      <td style="text-align: center;"><span style="font-size: 14px;">{{a.model.name}}</span></td>

      <td style="text-align: center;"><span style="font-size: 14px;">{{a.serial}}</span></td>

      <td style="text-align: center;"><span style="font-size: 14px;">{{a.certificate}}</span></td>

      <td style="text-align: center;"><span style="font-size: 14px;">{{a.due_date|date(\'M./Y\')}}</span></td>
    </tr>
  </tbody>
</table>
<span style="font-size: 14px;"><b>Results:</b><br>
</span>
<table wrap_code_open="{% filter unify_header_and_row(2) %}{% for s in spreadsheets %}{{s.description}}{% for t in s.table_json.table_data %}{% set table_index = loop.index0 %}" wrap_code_close="{% endfor %}{% endfor %}{% endfilter %}" wrap_caption="{{ s.table_json.uut_ranges[table_index].name }}" wrap_class="{{ s.table_json.lookup[table_index].range_index }}">
  <tbody>
    <tr>
      <th style="text-align: center;"><span style="font-size: 14px;">UUT</span><br>
      </th>

      <th style="text-align: center;"><span style="font-size: 14px;">Reference</span><br>
      </th>

      <th style="text-align: center;"><span style="font-size: 14px;">Error</span><br>
      </th>

      <th style="text-align: center;"><span style="font-size: 14px;">Admissive Error</span><br>
      </th>

      <th style="text-align: center;"><span style="font-size: 14px;">Uncertainty</span><br>
      </th>

      <th style="text-align: center;"><span style="font-size: 14px;">k</span><br>
      </th>

      <th style="text-align: center;"><span style="font-size: 14px;"></span><br>
      </th>
    </tr>

    <tr>
      <td style="text-align: center;">
        <div style="text-align: center;"><span style="font-size: 14px;">({{t._prefix}}<span style="-webkit-text-stroke-width: 0px; float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t._unit}})</span></span></div>
      </td>

      <td style="text-align: center;">
        <div style="text-align: center;"><span style="font-size: 14px;">({{t._prefix}}<span style="-webkit-text-stroke-width: 0px; color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t._unit}})</span></span></div>
      </td>

      <td style="text-align: center;">
        <div style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">({{t._prefix}}<span style="box-sizing: content-box;">{{t._unit}})</span></span></div>
      </td>

      <td style="text-align: center;">
        <div style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; box-sizing: content-box; color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">({{t._prefix}}{{t._unit}})</span></div>
      </td>

      <td style="text-align: center;">
        <div style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: center; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">({{t._prefix}}{{t._unit}})</span></div>
      </td>

      <td></td>

      <td></td>
    </tr>

    <tr>
      <td style="text-align: center;"><span style="font-size: 14px;">{{t.UUT}}</span></td>

      <td style="text-align: center;"><span style="font-size: 14px;">{{t.Reference}}</span></td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.e}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.MPE}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.U}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.k}}</span><br>
      </td>

      <td style="text-align: center;"><span style="-webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); color: rgb(51, 51, 51); float: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: 19.6000003814697px; orphans: auto; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: auto; word-spacing: 0px;">{{t.veff}}</span></td>
    </tr>
  </tbody>
</table>
<br>
<br>
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


