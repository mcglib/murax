class UserCreationMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL']

  # An email that goes out when a user is created via create_user_assign_role_v2.rake task. This container user password.
  def email_user_account_details
    @user_email = params[:user_email]
    @user_name = params[:user_name]
    @user_password = params[:user_password]
    @assigned_role = params[:assigned_role]
    mail(to: @user_email,
      subject: "An account has been created for you in eScholarship@McGill"
    )
  end

end
