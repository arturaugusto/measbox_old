class UserMailer < ActionMailer::Base
  default from: "donotreply@measbox.com"
  def welcome_email(user, raw)
  	@user = user
  	@token = raw
  	mail(to: @user.email, subject: 'Measbox invitation')
  end
end
