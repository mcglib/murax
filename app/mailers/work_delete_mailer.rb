class WorkDeleteMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          cc: ENV['ADMIN_EMAIL']

  # An email that goes out when a work is deleted in the repository. 
  def work_delete_email
    @user = params[:user]
    @deleted_files = params[:deleted_files]
    @deleted_file_ids = params[:deleted_file_ids]
    @deleted_work_title = params[:deleted_work_title]
    @deleted_work_id = params[:deleted_work_id]
    mail(to: ENV['CONTACT_US_EMAIL'],
      subject: "A work has been deleted in  #{ENV['RAILS_HOST']}"
    )
  end


  # An email that goes out when file/s are deleted in the repository.
  def file_delete_email
    @user = params[:user]
    @deleted_files_work_title = params[:deleted_files_work_title]
    @deleted_files_work_id = params[:deleted_files_work_id]
    @deleted_file_name = params[:deleted_file_name]
    @deleted_file_id = params[:deleted_file_id]
    mail(to: ENV['CONTACT_US_EMAIL'],
      subject: "A file has been deleted in  #{ENV['RAILS_HOST']}"
    )
  end
end
