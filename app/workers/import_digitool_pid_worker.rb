class ImportDigitoolPidWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, queue: "digitool_imports", max_retries: 0

  def perform(batch_id, pids, depositor)
    # Do something
    batch = Batch.find_by(id: batch_id)
    logger = ActiveSupport::Logger.new("#{Rails.root}/log/ui-import-csv-jid-#{batch_id}.log")

    begin
      start_time = Time.now
      logger.info "Starting the worker job  at #{start_time}"
      self.total = pids.count # setting total to 100
      if batch
        batch.update_attribute(:status, "Processing")
       # BatchProcessor.call(batch)
      end

      logger.info "#{msg}"
      #ImportEmailer.notifier(logger, msg, :success).deliver_now

      logger.close
    rescue => e
      msg = "Error occured during the import process: #{e}"
      puts "#{msg}"
      logger.error "#{msg}"
       # send error notification
       SystemNotifier.job_failed(self.class.name, e.to_s).deliver_now
    end
    logger.info 'Bulk import Everything'
  end
end
