class DuplicateWorksMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          cc: ENV['CONTACT_US_EMAIL']

  # An email that goes out when duplicate works are deleted with delete_works_by_work_ids.rake task.
  def email_deleted_wids
    @user_email = params[:user_email]
    @deleted_works = params[:deleted_works]
    mail(to: @user_email,
      subject: "eScholarship@McGill - Deleted duplicate WorkIDs"
    )
  end
end
