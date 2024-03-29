# Load the rails application.
require File.expand_path('../application', __FILE__)

# Initialize the rails application.
MeasWeb::Application.initialize!

# Sendgrid config on heroku
# https://devcenter.heroku.com/articles/sendgrid#ruby-rails
ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => 'measbox.com',
  :enable_starttls_auto => true
}