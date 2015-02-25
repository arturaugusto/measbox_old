class RolesController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  # GET /roles
  # GET /roles.json
  def index
    #@roles = Role.all
    respond_to do |format|
      format.html
      format.json { render json: ValuesDatatable.new(view_context) }
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Role.new(role_params)
    if @role.name == 'admin' then
      flash[:error] = 'Cant change or remove admin role'
      redirect_to(:back)
    else
      respond_to do |format|
        if @role.save
          format.html { redirect_to edit_role_path(@role), notice: 'Role was successfully created.' }
          format.json { render action: 'edit', status: :created, location: @role }
        else
          format.html { render action: 'new' }
          format.json { render json: @role.errors, status: :unprocessable_entity , notice: 'Bosta'}
        end
      end
    end
  end

  # PATCH/PUT /roles/1
  # PATCH/PUT /roles/1.json
  def update
    if role_params[:name] == 'admin' then
      flash[:error] = 'Cant change or remove admin role'
      redirect_to(:back)
    else    
      respond_to do |format|
        if @role.update(role_params)
          format.html { redirect_to edit_role_path(@role), notice: 'Role was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @role.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to roles_url }
      format.json { head :no_content }
    end
  end

  private
    def prevent_remove_admin
      #Rails.logger.info @role.name
      Rails.logger.info role_params
      if @role.name == 'admin'
        flash[:error] = 'Cant change or remove admin role'
        redirect_to(:back)
      end
    end  

    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:name, :title, :description, :the_role, :id)
    end
end
