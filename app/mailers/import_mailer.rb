class ImportMailer < ApplicationMailer
  default from: "from@example.com"

  def sample_email(user)
    @user = user
    mail(to: @user.email, subject: 'Test email from importLog')
  end
end
