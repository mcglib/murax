class ImportDigitoolPidWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # enables job status tracking
  sidekiq_options retry: true, queue: "digitool_migrate", max_retries: 2

  def expiration
        @expiration ||= 60 * 60 * 24 * 30 # 30 days
  end

  def perform(pid,depositor, logger)
    begin
      start_time = Time.now
      puts "Processing pid #{pid}"
      sleep(30)
      import_rec = Migrate::ImportRecord.call(pid, batch_id, depositor, logger)
    rescue => e
      msg = "Error occured during the import process: #{e}"
      puts "#{msg}"
       # send error notification
    end
  end
end
