class PasswordMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL']

  # An email that goes out when a user password is changed via change_user_password.rake task.
  def email_user_password
    @user_email = params[:user_email]
    @user_password = params[:user_password]
    mail(to: @user_email,
      subject: "eScholarship@McGill - request completed"
    )
  end

end
