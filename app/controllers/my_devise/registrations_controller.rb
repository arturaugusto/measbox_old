class MyDevise::RegistrationsController < Devise::RegistrationsController
	skip_before_filter :verify_authenticity_token, :only => [:create]
	def new
		super
	end

	def create
		if (verify_recaptcha) or (Rails.env.development?)
			build_resource(sign_up_params)
			resource_saved = resource.save
			yield resource if block_given?
			if resource_saved
				# Set user to admin if its the first user created
				if User.count == 1
					resource.update( role: Role.with_name(:admin) )
				else
					resource.update( role: Role.with_name(:inactive) )
				end
				if resource.active_for_authentication?
					set_flash_message :notice, :signed_up if is_flashing_format?
					sign_up(resource_name, resource)
					respond_with resource, location: after_sign_up_path_for(resource)
				else
					set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
					expire_data_after_sign_in!
					respond_with resource, location: after_inactive_sign_up_path_for(resource)
				end
			else
				clean_up_passwords resource
				flash.now[:error] = @user.errors.to_a
				respond_with resource
			end      	
			#super
		else
			build_resource(sign_up_params)
			clean_up_passwords(resource)
			flash.now[:error] = "There was an error with the recaptcha code below. Please re-enter the code."      
			flash.delete :recaptcha_error
			render :new
		end
	end

	def update
		super
	end
end 