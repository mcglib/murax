namespace :migration do
    require 'fileutils'
    require 'htmlentities'
    require 'csv'
    require 'yaml'
    # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
    require 'tasks/migration/migration_logging'
    require 'tasks/migration/migration_constants'
    require "tasks/migration/services/migrate_service"
    require 'tasks/migration/services/metadata_parser'
    require 'tasks/migration/services/import_service'
    require 'tasks/migration_helper'

    desc 'Migrate a Digitool object with a PID and its related items eg: bundle exec rake migrate:import_record[pid]'
    task :import_record, [:pid] => :environment do |t, args|
      user_email = ENV['DEFAULT_DEPOSITOR_EMAIL'].tr('"','')

      pids = args[:pid].split(' ').map{ |s| s.to_i } # first argument
      # check if we go other pids
      #pids = args.extra # the rest of the arguments


      # Lets create a batch no
      @depositor = User.where(email: user_email).first
      batch = Batch.new({:no => pids.count, :name => 'single_import', :started => Time.now,
                         :finished => Time.now, user: @depositor})
      batch.save!

      # start processing
      process_import_pids(batch.id, pids, @depositor) if pids.present?

      # update the batch that its finished
      batch.finished = Time.now
      batch.save!

      # Email error report
      send_error_report(batch, @depositor)
    end

    def process_import_pids(batch_id, pids, user)
      admin_set = ENV['DEFAULT_ADMIN_SET'].tr('"', '')

      amount_to_import = pids.count
      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      logger = ActiveSupport::Logger.new("log/single-import-batch-#{batch_id}-#{datetime_today}.log")
      logger.info "Task started at #{start_time}"

      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: admin_set).count == 0
        puts "No admin set found. Please create one"
        exit
      end

      logger.info "Starting to import #{amount_to_import} items."
      puts "Starting to import #{amount_to_import} items."

      successes = 0
      errors = 0
      total_items = pids.count
      pids.each_with_index do | pid, index |
        puts "#{index}/#{total_items}:-  #{Time.now.to_s}: Processing the item  #{item}"
        import_log = ImportLog.new({:pid => pid, :date_imported => Time.now, :batch_id => batch_id})
        begin
            import_service = Migration::Services::ImportService.new({:pid => pid, :admin_set => admin_set}, user, logger)
            import_rec = import_service.import
            if import_rec[:error].nil?
              import_log.attributes = import_rec
              AddWorkToCollection.call(import_rec[:work_id],
                                       import_rec[:work_type],
                                       import_rec[:collection_id])
              successes += 1
              import_log.imported  = true
            else
              import_log.imported = false
              errors += 1
              import_log.error = "#{import_rec[:error]}"
            end

         rescue StandardError => e
            errors += 1
            import_log.imported  = false
            import_log.error = "#{e}: #{e.class.name} "
            logger.error "Error importing #{pid}: #{e}: #{e.class.name}"
        end
        import_log.save
      end
      puts "Processed #{successes} work(s), #{errors} error(s) encountered"
      logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"
      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{pids.map(&:inspect).join(', ')} in #{duration} minutes"
      log.info "Task finished at #{end_time} and lasted #{duration} minutes."

      pids

    end

    def send_error_report(batch, user)
      @errors = batch.import_log.not_imported
      # Find all items that are part of a given batch
      ImportMailer.import_email(user,batch).deliver
    end
end
