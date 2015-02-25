class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_action :role_required, only: [:update, :destroy, :create, :edit, :index]
  before_filter :authenticate_user!
  def new
    @user = User.new
  end

	def show
		@user = User.find(params[:id])
		#unless @user == current_user
		  #redirect_to :back, :alert => "Access denied."
		#end
	end	
  def invite
    @roles = Role.all
    @user = User.new(user_params)
    rand_password = ('0'..'z').to_a.shuffle.first(8).join
    @user.password = rand_password
    @user.skip_confirmation!
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)
    @user.reset_password_token = enc
    @user.reset_password_sent_at = Time.now.utc
    if @user.save
      UserMailer.welcome_email(@user, raw).deliver
      redirect_to users_path, notice: "Invitation sent!"
    else
      flash.now[:error] = @user.errors.to_a
      render :new
    end
  end

  def index
    @users = User.all
    respond_to do |format|
      format.html
      format.json { render json: ValuesDatatable.new(view_context) }
    end    
  end

  def edit
    @user = current_user
  end

  def manage
    @user = User.find(params[:user_id])
  end

  def manage_update
    @user = User.find(params[:user_id])
    admin_role_id = Role.where(name: 'admin').first.id
    count_admins = User.where(role_id: admin_role_id).count
    if (@user.admin?) and ( (params[:user][:role_id]) != admin_role_id) and (count_admins == 1)
      flash.now[:error] = "You cannot remove the admin privilege from this user. Your system needs at last one admin."
      render "manage"
    else
      if @user.update_without_password(user_params)
        # Sign in the user by passing validation in case his password changed
        sign_in @user, :bypass => true
        redirect_to users_path, notice: "Updated profile." 
      else
        flash.now[:error] = @user.errors.to_a
        render "manage"
      end
    end
  end

  def update
    @user = current_user
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_url, notice: "Updated profile." 
    else
      flash.now[:error] = @user.errors.to_a
      render "edit"
    end
  end

  def destroy
    @user = current_user
    raise "Cannot delete" unless params[:current_password] != @user.current_password
    @user.destroy
    redirect_to root_url, notice: "User Deleted." 
  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.required(:user).permit(:password, :password_confirmation, :email, :current_password, :role_id, :company_id, :title, :name)
  end

  
end
