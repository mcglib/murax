# frozen_string_literal: true
class BulkImportCsvJob < Murax::ApplicationJob
  queue_as :default

  sidekiq_options retry: true, queue: "imports", max_retries: 0

  def perform(batch_id)
    batch = Batch.find_by(id: batch_id)
    logger = ActiveSupport::Logger.new("#{Rails.root}/log/murax-bulk-import-csv-jid-#{batch_id}.log")

    begin
      start_time = Time.now
      logger.info "Starting the worker job  at #{start_time}"
      raise "#{filepath} db file was not found in the specified directory.." if !File.exist?(real_filepath)
      self.total = 100 # setting total to 100
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
    counter = 0
  end
end
