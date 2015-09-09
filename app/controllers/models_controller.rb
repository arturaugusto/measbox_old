class ModelsController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]  
  before_action :set_model, only: [:show, :edit, :update, :destroy]

  def autocomplete
    @models = Model.tagged_with([params[:tag]], :wild => true, :any => true) # Find by tag param, allow wildcard
    .map { |s| s.model_list } # map to arrays
    .reduce(:+) # recude do one array and without duplicate
    #.tagged_with(params[:tags])
    if @models then
      render json: @models.uniq
    else
      render json: []
    end
  end



  # GET /models
  # GET /models.json
  def index
    #@models = Model.all
    respond_to do |format|
      format.html
      format.json { render json: ValuesDatatable.new(view_context) }
    end    
  end

  # GET /models/1
  # GET /models/1.json
  def show
  end

  # GET /models/new
  def new
    @model = Model.new
  end

  # GET /models/1/edit
  def edit
  end

  # POST /models
  # POST /models.json
  def create
    @model = Model.new(model_params)

    respond_to do |format|
      if @model.save
        format.html { redirect_to edit_model_path(@model), notice: 'Model was successfully created.' }
        format.json { render action: 'edit', status: :created, location: @model }
      else
        format.html { render action: 'new' }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /models/1
  # PATCH/PUT /models/1.json
  def update
    respond_to do |format|
      if @model.update(model_params)
        format.html { redirect_to edit_model_path(@model), notice: 'Model was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /models/1
  # DELETE /models/1.json
  def destroy
    @model.destroy
    respond_to do |format|
      format.html { redirect_to models_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model
      @model = Model.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def model_params
      params.require(:model).permit(:name, :manufacturer_id, :kind_id, :tags, :model_list, :code)
    end
end
