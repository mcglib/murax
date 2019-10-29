class WorkDeleteMailerPreview < ActionMailer::Preview
  def work_delete_email
    WorkDeleteMailer.with(user: User.first, deleted_work_title: @title, deleted_work_id: @deleted_work_id).work_delete_email
  end

  def file_delete_email
    WorkDeleteMailer.with(user: User.first, deleted_files_work_title: parent, deleted_files_work_id: parent_id, deleted_files: deleted_file_name, deleted_file_id: deleted_file_id).file_delete_email.deliver_now
  end
end
