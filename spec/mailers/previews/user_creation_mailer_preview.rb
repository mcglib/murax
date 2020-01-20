class UserCreationMailerPreview < ActionMailer::Preview
  def email_user_account_details
    UserCreationMailer.with(user_email: 'u.email', user_name: 'u.display_name', user_password: 'generated_password', assigned_role: 'existing_role').email_user_account_details
  end

end
