class MyDevise::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, :only => [:create, :destroy]
  def new
    #@laboratory = Laboratory.find(Laboratory.current_id)
    if Laboratory.current_id == nil
      redirect_to :controller=> '/laboratories', :action => 'new'
    else
      super
    end
  end

  def destroy
    reset_session
    session[:user_id] = nil
    redirect_to new_user_session_path, notice: "Logged out!"
  end
  def edit
    # add custom logic here
    @user = current_user
    @laboratory = Laboratory.find(Laboratory.current_id)
    super
  end

end 