class WorkDeleteMailerPreview < ActionMailer::Preview
  def work_delete_email
    WorkDeleteMailer.with(user: User.first, deleted_work_title: @title, deleted_work_id: @deleted_work_id).work_delete_email
  end

end
