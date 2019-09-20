# Preview all emails at http://localhost:3000/rails/mailers/import_mailer
class ImportMailerPreview < ActionMailer::Preview
  def import_mail_preview
    batch = Batch.find(3)
    ImportMailer.import_email(User.first, batch)
  end

end
