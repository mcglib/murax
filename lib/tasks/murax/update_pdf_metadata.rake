require 'active_record'

namespace :murax do
  desc 'Update a main representative pdf metadata for a given  workid(s). Multiple work ids can be passed'
  task :update_pdf_metadata, [:workids] => :environment do |task, args|
    if args.count < 1
        puts 'Usage: bundle exec rake murax:update_pdf_metadata["<samvera-work-id>[ <samvera-work-id>]..."]'
        next
    end
    workids = args[:workids].split(' ')
    faf = FetchAFile.new
    faf.by_uri(f)
    
    # start processing
    process_update_pdfs(workids) if workids.present?
    
    # Email error report
    send_error_report(workids, @depositor)
  end

  def process_update_pdfs(workids)
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      logger = ActiveSupport::Logger.new("log/update-pdf-metadata-#{datetime_today}.log")
      logger.info "Task started at #{start_time}"
      successes = 0
      errors = 0
      total_items = workids.count

      workids.each_with_index do | wkid, index |
        puts wkid
        puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{index}/#{total_items}  : Processing the workid #{wkid}"

        begin

          successes += 1
        rescue StandardError => e
          errors += 1
          import_log.imported  = false
          import_log.error = "#{e}: #{e.class.name} "
          logger.error "Error updating the PDF file #{pid}: #{e}: #{e.class.name}"
        end

      end
      
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"
      logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"
      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{pids.map(&:inspect).join(', ')} in #{duration} minutes"
      logger.info "Task finished at #{end_time} and lasted #{duration} minutes."

      # Return the workids
      workids
  end

end
