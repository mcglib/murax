class ImportMailer < ApplicationMailer
  default from: ENV['ADMIN_EMAIL']

  def import_email(user, batch)
    @user = user
    @batch = batch
    @errors = batch.import_log.where(:imported => false)
    #@error_logs = batch.
    #mail(to: @user.email,
    mail(to: "mutugi.gathuri@mcgill.ca",
         subject: "Import report: Batch import no:#{batch.id} finished at #{batch.finished}"
    )
  end

end
