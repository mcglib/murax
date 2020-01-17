class UserCreationMailerPreview < ActionMailer::Preview
  def user_password_email
    UserCreationMailer.with(user_email: 'u.email', user_name: 'u.display_name', user_password: 'generated_password', assigned_role: 'existing_role').user_password_email
  end

end
