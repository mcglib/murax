class WorkDeleteMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          cc: ENV['ADMIN_EMAIL']

  def work_delete_email
    @user = params[:user]
    @deleted_work_title = params[:deleted_work_title]
    @deleted_work_id = params[:deleted_work_id]
    mail(to: ENV['CONTACT_US_EMAIL'],
      subject: "A work has been deleted in  #{ENV['RAILS_HOST']}"
    )
  end

end
