# TheRole.config.param_name => value

TheRole.configure do |config|
  config.login_required_method = :authenticate_user!
  config.layout                     = :application

  config.default_user_role          = :user
  # The folow param is false, becouse I use multitenacy!
  # Im using other aproach
  config.first_user_should_be_admin = false
  #config.access_denied_method       = :access_denied
  # config.destroy_strategy           = :restrict_with_exception # can be nil
end