class ImportMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          cc: ENV['ADMIN_EMAIL']

  def import_email(user, batch)
    @user = user
    @batch = batch
    #@errors = batch.import_log.where(:imported => false)
    byebug
    @errors = batch.import_log.not_imported
    #@error_logs = batch.
    mail(to: @user.email,
      subject: "#{ENV['RAILS_HOST']} import report: Batch import no:#{batch.id}"
    )
  end

end
