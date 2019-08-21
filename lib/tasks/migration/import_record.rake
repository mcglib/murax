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
    require 'tasks/migration_helper'
    # bundle exec rake migrate:digitool_item -- -p 12007 -c 'thesis'
    desc 'Migrate a Digitool object with a PID and its related items eg: bundle exec rake migrate:digitool_item[pid,localcollectioncode,itemtype, collectionid]'
    task :import_record, [:pid,:localcollectioncode,:itemtype, :collectionid] => :environment do |t, args|

      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

      start_time = Time.now
      puts "[#{start_time.to_s}] Start migration of pid item #{args[:pid]} to the collection #{args[:collectionid]}"
    
      log = ActiveSupport::Logger.new("log/digitool-import-#{args[:pid]}.log")
      start_time = Time.now
      log.info "Task started at #{start_time}"

      # get the migration config
      migration_config = MigrationHelper::get_migration_config(args[:collectionid])

      puts "Could not find the migration config for #{args[:collectionid]} collection" if migration_config.nil?

      # lets create the tmp file location if it does not exist
      FileUtils::mkdir_p migration_config['tmp_file_location']

      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
          User.where(email: migration_config['depositor_email']).count > 0

        @depositor = User.where(email: migration_config['depositor_email']).first

        migrate_service = Migration::Services::MigrateService.new(migration_config,
                                             @depositor)

        work_id = migrate_service.import_record(args[:pid], log)
        log.info "Added  pid #{pid} to work id #{work_id}."
        puts "Adding the workid: #{work_id} to the collection #{migration_config['samvera_collection_id']}"
        migrate_service.add_works_to_collection([work_id], migration_config['samvera_collection_id'])

      else
        puts 'The default admin set or specified depositor does not exist'
      end

      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{args[:collection]} in #{duration} minutes"
      log.info "Task finished at #{end_time} and lasted #{duration} minutes."
      log.close

      end_time = Time.now
      puts "[#{end_time.to_s}] Completed migration of #{args[:collection]} in #{duration} seconds"


    end


    desc 'Migrate a Digitool object with a PID and its related items eg: bundle exec rake migrate:record[pid]'
    task :record, [:pid] => :environment do |t, args|
      pid = args[:pid]
      item = DigitoolItem.new({ :pid => pid}) if pid

      ##Get the dctypes
      
      dc_types = item.metadata_hash["type"] if !item.is_waiver?
      dc_types = dc_types.map(&:inspect).join(', ') if dc_types.kind_of?(Array)

      # Get the lc_code
      lc_code = item.metadata_hash["localcollectioncode"]

      #Determine the worktype from dc:type and lc_code
      work_type = MigrationHelper::get_worktype(dc_types, lc_code)

      # Determine the samvera collection from the worktype and lc_code
      collection_id = MigrationHelper::get_samvera_collection_id(work_type, lc_code) if work_type.present?

      # get the migration config
      migration_config = MigrationHelper::get_migration_config(collection_id)
      # lets create the tmp file location if it does not exist
      FileUtils::mkdir_p migration_config['tmp_file_location']

      puts "#{work_type}, #{collection_id}, #{lc_code}"

      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
          User.where(email: ENV['DEFAULT_DEPOSITOR_EMAIL']).count > 0
          start_time = Time.now
          puts "[#{start_time.to_s}] Start migration of pid item #{args[:pid]} to the collection #{collection_id}"
          start_time = Time.now
          log.info "Task started at #{start_time}"

          @depositor = User.where(email: migration_config['depositor_email']).first

          migrate_service = Migration::Services::MigrateService.new(migration_config,
                                               @depositor)

          work_id = migrate_service.import_records([args[:pid]], log, work_type)

          # Add the work to the collection id
          log.info "Added  pid #{pid} to work id #{work_id}."
          puts "Adding the workid: #{work_id} to the collection #{collection_id}"
          migrate_service.add_works_to_collection([work_id], collection_id)

      else
        puts 'The default admin set or specified depositor does not exist'
      end

      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{args[:collection]} in #{duration} minutes"
      log.info "Task finished at #{end_time} and lasted #{duration} minutes."
      log.close

      end_time = Time.now
      puts "[#{end_time.to_s}] Completed migration of #{args[:collection]} in #{duration} seconds"
    end

  end
