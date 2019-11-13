class BatchImportDigitoolPidWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # enables job status tracking
  sidekiq_options retry: false, queue: "digitool_migrate", max_retries: 0

  
  def expiration
        @expiration ||= 60 * 60 * 24 * 30 # 30 days
  end

  def perform(batch_id, pids, depositor)
    # Do something
    admin_set = ENV['DEFAULT_ADMIN_SET'].tr('"', '')
    batch = Batch.find_by(id: batch_id)
    datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
    start_time = Time.now
    logger = ActiveSupport::Logger.new("log/ui-import-batch-#{batch_id}-#{datetime_today}.log")
    logger.info "Task started at #{start_time}"

    if AdminSet.where(title: admin_set).count == 0
      puts "No admin set found. Please create one"
      exit
    end
    @user = User.where(email: depositor).first
    # a job for each pid
    begin
      start_time = Time.now
      total = pids.count # setting total to 100
      successes = 0
      errors = 0
      pids.each_with_index do |pid, index|
        puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{index}/#{total}  : Processing the item  #{pid}"
        import_rec = Migrate::ImportRecord.call(pid, batch_id, @user, logger)
        successes += 1 if import_rec.present?
        errors += 1 if !import_rec.present?

      end
    rescue StandardError => e
      msg = "Error occured during the import process: #{e}"
      puts "#{msg}"
      logger.error "#{msg}"
       # send error notification
       #SystemNotifier.job_failed(self.class.name, e.to_s).deliver_now
    end

    puts "Processed #{successes} work(s), #{errors} error(s) encountered"
    logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"
    end_time = Time.now
    duration = (end_time - start_time) / 1.minute
    puts "[#{end_time.to_s}] Finished the  migration of #{pids.map(&:inspect).join(', ')} in #{duration} minutes"
    logger.info "Task finished at #{end_time} and lasted #{duration} minutes."

    # send report
    @errors = batch.import_log.not_imported
    # Find all items that are part of a given batch
    ImportMailer.import_email(@user,batch).deliver

  end
end
