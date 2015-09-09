class ApplicationController < ActionController::Base
	include TheRole::Controller
	#include TheRole::Api::User
	#before_filter :configure_permitted_parameters, if: :devise_controller?

	#before_filter :configure_permitted_parameters, if: :devise_controller?

	#def configure_permitted_parameters
	#	devise_parameter_sanitizer.for(:account_update) { |u| 
	#		u.permit(:password, :password_confirmation, :current_password, :laboratory_id)
	#	}
	#end

	def after_sign_in_path_for(resource_or_scope)
		services_path
	end

	def after_sign_out_path_for(resource_or_scope)
		new_user_session_path
	end

private
  #def current_user
  #  @current_user ||= User.find(session[:user_id]) if session[:user_id]
  #end
  helper_method :current_user  
	def current_laboratory
		Laboratory.find_by_subdomain(request.subdomain.split('.').last) || nil
	end
	helper_method :current_laboratory
	def scope_current_laboratory
		if current_laboratory != nil
			Laboratory.current_id = current_laboratory.id
		end
		yield
	ensure
		Laboratory.current_id = nil
	end
protected
	def configure_permitted_parameters
	  devise_parameter_sanitizer.for(:sign_up) do |u|
	    u.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :laboratory_id)
	  end
	  devise_parameter_sanitizer.for(:account_update) do |u|
	    u.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation, :laboratory_id)
	  end
	end
	# Prevent CSRF attacks by raising an exception.
	protect_from_forgery with: :exception
  def access_denied
    flash[:error] = t('the_role.access_denied')
    #redirect_to root_url
    redirect_to(:back)
  end	

	# For APIs, you may want to use :null_session instead.
	around_filter :scope_current_laboratory
end
