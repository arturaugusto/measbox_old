class ReportsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]
  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  # GET /reports.json
  #def index
  #  @reports = Report.all
  #end

  # GET /reports/1
  # GET /reports/1.json
  def show

    respond_to do |format|
      @laboratory = Laboratory.find(@report.laboratory_id)
      pdf_options = @report.pdf_options
      #mathjax_js = "KGZ1bmN0aW9uKCl7ZnVuY3Rpb24gdCh0KXt2YXIgZT0iLk1hdGhKYXggLm1uIHtiYWNrZ3JvdW5kOiBpbmhlcml0O30gLk1hdGhKYXggLm1pIHtjb2xvcjogaW5oZXJpdDt9IC5NYXRoSmF4IC5tbyB7YmFja2dyb3VuZDogaW5oZXJpdDt9Ijt2YXIgYT10LmNyZWF0ZUVsZW1lbnQoInN0eWxlIik7YS5pbm5lclRleHQ9ZTt0cnl7YS50ZXh0Q29udGVudD1lfWNhdGNoKG4pe310LmdldEVsZW1lbnRzQnlUYWdOYW1lKCJib2R5IilbMF0uYXBwZW5kQ2hpbGQoYSk7dmFyIGk9dC5jcmVhdGVFbGVtZW50KCJzY3JpcHQiKSxvO2kuc3JjPSIvL2Nkbi5tYXRoamF4Lm9yZy9tYXRoamF4L2xhdGVzdC9NYXRoSmF4LmpzP2NvbmZpZz1UZVgtTU1MLUFNX0hUTUxvck1NTC5qcyI7aS50eXBlPSJ0ZXh0L2phdmFzY3JpcHQiO289Ik1hdGhKYXguQWpheC5jb25maWcucGF0aFsnQ29udHJpYiddPScvL2Nkbi5tYXRoamF4Lm9yZy9tYXRoamF4L2NvbnRyaWInO01hdGhKYXguSHViLkNvbmZpZyh7dGV4MmpheDp7aW5saW5lTWF0aDpbWyckJywnJCddLFsnJCQnLCAnJCQnXV0sZGlzcGxheU1hdGg6W1snXFxcXFsnLCdcXFxcXSddXSxwcm9jZXNzRXNjYXBlczp0cnVlfSxUZVg6e2V4dGVuc2lvbnM6IFsnW0NvbnRyaWJdL3h5amF4L3h5cGljLmpzJ119fSk7TWF0aEpheC5IdWIuU3RhcnR1cC5vbmxvYWQoKTsiO2lmKHdpbmRvdy5vcGVyYSlpLmlubmVySFRNTD1vO2Vsc2UgaS50ZXh0PW87dC5nZXRFbGVtZW50c0J5VGFnTmFtZSgiaGVhZCIpWzBdLmFwcGVuZENoaWxkKGkpfWZ1bmN0aW9uIGUoZSl7aWYoZS5NYXRoSmF4PT09dW5kZWZpbmVkKXt0KGUuZG9jdW1lbnQpfWVsc2V7ZS5NYXRoSmF4Lkh1Yi5RdWV1ZShuZXcgZS5BcnJheSgiVHlwZXNldCIsZS5NYXRoSmF4Lkh1YikpfX12YXIgYT1kb2N1bWVudC5nZXRFbGVtZW50c0J5VGFnTmFtZSgiaWZyYW1lIiksbixpO2Uod2luZG93KTtmb3Iobj0wO248YS5sZW5ndGg7bisrKXtpPWFbbl0uY29udGVudFdpbmRvd3x8YVtuXS5jb250ZW50RG9jdW1lbnQ7aWYoIWkuZG9jdW1lbnQpaT1pLnBhcmVudE5vZGU7ZShpKX19KSgpOw=="
      #mathjax_js = "d2luZG93LmRvY3VtZW50LndyaXRlbG4oJ2xhbGFsYScp"
      opts = {:pdf => "", :javascript_delay => "1000", :disable_smart_shrinking => false}.merge(pdf_options).deep_symbolize_keys

      format.html
      format.pdf do
          render(opts)
          #render :pdf => "show"
      end
    end
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
    @laboratory = Laboratory.find(@report.laboratory_id)
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

    # This will be implemented on client side now
    #x = apply_template(nil, opts, @report.service.information)
    #def apply_template(parent, myHash, locals)
    #  myHash.each {|key, value|
    #    if value.is_a?(Hash) then
    #      apply_template(key, value, locals)
    #    else
    #      myHash[key] = Mustache.render(value, locals)
    #    end
    #  }
    #end

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
      params.require(:report).permit(:name, :value, :service_id, :laboratory_id, :report_template_id, :pdf_options, :value_html)
    end
end