namespace :migration do
  require 'fileutils'
  require 'htmlentities'
  require 'csv'
  require 'yaml'

  # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
  require 'tasks/migration/migration_logging'
  require 'tasks/migration/migration_constants'
  require "tasks/migration/services/migrate_service"
  require "tasks/migration/services/id_mapper"
  require 'tasks/migration/services/metadata_parser'

  # bundle exec rake migrate:digitool -- -c 'thesis' -f spec/fixtures/digitool/ethesis-pids.csv
  desc 'Batch migrate digitool records from a list of PIDS in a  CSV file'
  task :digitool => :environment do
    options = {
          collection_name: 'thesis',
          csv_file: 'spec/fixtures/digitool/ethesis.csv',
    }
    o = OptionParser.new
    o.banner = "Usage: rake migrate:digitool -- -c 'thesis' -f spec/fixtures/digitool/ethesis.csv"
    o.on('-c COLLECTION_NAME') { |collect|
      options[:collect] = collect
    }
    o.on('-f FILENAME') { |csv_file|
      options[:csv_file] = csv_file
    }
    
    # temporary location for file download
    
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)

    log = ActiveSupport::Logger.new('log/digitool-import.log')
    start_time = Time.now
    log.info "Task started at #{start_time}"

    @pid_list = File.read(options[:csv_file]).strip.split(",")

    # get the migration config
    migration_config = get_migration_config(options[:collect])

    # lets create the tmp file location if it does not exist
    FileUtils::mkdir_p migration_config['tmp_file_location']


    if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
        User.where(email: migration_config['depositor_email']).count > 0

      @depositor = User.where(email: migration_config['depositor_email']).first

      migrate_service = Migrate::Services::MigrateService.new(migration_config,
                                           @depositor)
      # insert all the metadata and files
      puts "Object count:  #{@pid_list.count.to_s}"
      # lets chunck the job
      @pid_list.each_slice(100) do | chunck |
        puts "Object count:  #{chunck.count.to_s}"
        migrate_service.import_records(chunck, log)
      end

      # add the collections to the last batch of import

    else
      puts 'The default admin set or specified depositor does not exist'
    end

    end_time = Time.now
    duration = (end_time - start_time) / 1.minute
    puts "[#{end_time.to_s}] Finished the  migration of #{options[:collect]} in #{duration}"
    log.info "Task finished at #{end_time} and lasted #{duration} minutes."
    log.close

  end

  private

    def get_uuid_from_path(path)
      path.slice(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/)
    end

    def create_filepath_hash(filename, hash)
      File.open(filename) do |file|
        file.each_with_index do |line, index|
          next if index == 0
          value = line.strip
          key = value
          if !key.blank?
            hash[key] = value
          end
        end
      end
    end

    def read_file_csv(filename, array)
      array = data.split(",")
    end
end
