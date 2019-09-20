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
      admin_set = ENV['DEFAULT_ADMIN_SET'].tr('"', '')
      user_email = ENV['DEFAULT_DEPOSITOR_EMAIL'].tr('"','')

      pid = args[:pid]
      #puts "#{work_type}, #{collection_id}, #{lc_code}"
      start_time = Time.now
      log = ActiveSupport::Logger.new("log/digitool-import-#{pid}.log")
      log.info "Task started at #{start_time}"

      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: admin_set).count != 0 &&
          User.where(email: user_email).count > 0
          start_time = Time.now

          @depositor = User.where(email: user_email).first

          successes = 0
          errors = 0
          batch = Batch.new({:no => 1, :name => "single_import", :started => Time.now, :finished => Time.now, user: @depositor})
          batch.save!
          import_log = ImportLog.new({:pid => item, :date_imported => Time.now, :batch_id => batch.id})
          begin
              import_service = Migration::Services::ImportService.new({:pid => pid,
                                                                       :admin_set => admin_set}, @depositor, log)

              import_rec = import_service.import
              if import_rec.present?
                import_log.attributes = import_rec
                AddWorkToCollection.call(import_rec[:work_id],
                                         import_rec[:work_type],
                                         import_rec[:collection_id])
                successes += 1
                import_log.imported  = true
              end

          rescue StandardError => e
              errors += 1
              import_log.imported  = false
              import_log.error = "#{e}: #{e.class.name} "
              log.error "Error importing #{pid}: #{e}: #{e.class.name}"
          end
          import_log.save

      else
        puts 'The default admin set or specified depositor does not exist'
      end

      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{pid} in #{duration} minutes"
      log.info "Task finished at #{end_time} and lasted #{duration} minutes."
      log.close
    end
  end
