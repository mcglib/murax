namespace :migration do
  require 'fileutils'
  require 'htmlentities'
  require 'tasks/migration/migration_logging'
  require 'tasks/migration/migration_constants'
  require 'csv'
  require 'yaml'

  # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
  require "tasks/migration/services/migrate_service"
  require "tasks/migration/services/id_mapper"
  require 'tasks/migration/services/metadata_parser'
  require 'tasks/migration_helper'

  ####Reports migration (bundle exec rake migrate:reports -- -c 'thesis' -f spec/fixtures/digitool/ethesis-pids.csv) ######
  desc 'batch migrate reports from CSV file with PIDs. '
  task :reports, [:work_type, :collection,:csv_file] => :environment do |t, args|

    require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

    start_time = Time.now
    puts "[#{start_time.to_s}] Start migration of #{args[:collection]}"


    log = ActiveSupport::Logger.new('log/digitool-import-reports.log')
    start_time = Time.now
    log.info "Task started at #{start_time}"

    @pid_list = File.read("#{Rails.root}/#{args[:csv_file]}").strip.split(",")

    # get the migration config
    migration_config = MigrationHelper::get_migration_config(args[:collection])

    puts "Could not find the migration config for #{args[:collection]} collection" if migration_config.nil?

    # lets create the tmp file location if it does not exist
    FileUtils::mkdir_p migration_config['tmp_file_location']



    # The default admin set and designated depositor must exist before running this script
    if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
        User.where(email: migration_config['depositor_email']).count > 0

      @depositor = User.where(email: migration_config['depositor_email']).first

      migrate_service = Migration::Services::MigrateService.new(migration_config,
                                           @depositor)

      # insert all the metadata and files
      puts "Object count:  #{@pid_list.count.to_s}"

      # Lets clean the csv file because of the quotes
      @pids = @pid_list.map do | item | item.gsub!(/\A"|"\Z/, '') end

      # lets chunck the job
      @pids.each_slice(3) do | chunck |
        puts "Object count:  #{chunck.count.to_s}"
        created_work_ids = migrate_service.import_records(chunck, log)
        puts "Adding the following workids: #{created_work_ids.split(",")} to the collection #{migration_config['samvera_collection_id']}"
        migrate_service.add_works_to_collection(created_work_ids, migration_config['samvera_collection_id'])
      end

      # add the collections to the last batch of import
      # Now we need to add the pids to the collection

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

