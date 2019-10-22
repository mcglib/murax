class WorkDeleteMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          cc: ENV['ADMIN_EMAIL']

  def work_delete_email
    @user = params[:user]
    @deleted_work_title = params[:deleted_work_title]
    @deleted_work_id = params[:deleted_work_id]
    @deleted_work_type = params[:deleted_work_type]
    mail(to: 'awais.khalid@mcgill.ca',
      subject: "#{ENV['RAILS_HOST']} - A work has been deleted"
    )
  end

end
