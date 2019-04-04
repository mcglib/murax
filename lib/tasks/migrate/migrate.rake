namespace :migrate do
  require 'fileutils'
  require 'tasks/migration/migration_logging'
  require 'htmlentities'
  require 'tasks/migration/migration_constants'
  require 'csv'
  require 'yaml'

  # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
  require "tasks/migrate/services/ingest_service"
  require "tasks/migrate/services/id_mapper"
  require 'tasks/migrate/services/metadata_parser'

  # temporary location for file download
  @temp = 'lib/tasks/ingest/tmp'
  FileUtils::mkdir_p @temp

  # bundle exec rake migrate::digitool_item -- -p 12007 -c 'thesis'
  desc 'Migrate a Digitool object with a PID and its related items'
  task :digitool_item =>:environment do
    options = {
          pid: '',
          collection: 'thesis'
    }
    o = OptionParser.new
    o.banner = "Usage: rake migrate:digitool_item [options]"
    o.on('-p PID') { |pid|
      options[:pid] = pid
    }
    o.on('-c COLLECTION') { |collection|
      options[:collection] = collection
    }
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    start_time = Time.now
    puts "#{options}"
    puts "[#{start_time.to_s}] Start migration of #{options[:pid]}"

    # 0. Get the related pids

    # 1. Fetch the metadata
    # 2. Request cleanup of metadata
    # 3. Import the metadata
  end 




  desc 'batch migrate records from CSV file with PIDs'
  task :works, [:collection, :configuration_file, :mapping_file] => :environment do |t, args|

    require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

    start_time = Time.now
    puts "[#{start_time.to_s}] Start migration of #{args[:collection]}"

    config = YAML.load_file(args[:configuration_file])
    collection_config = config[args[:collection]]

    @collection = FindOrCreateCollection.create(args[:collection], collection_config['depositor_email'])


    # The default admin set and designated depositor must exist before running this script
    if AdminSet.where(title: "Admin Set").count != 0 &&
        User.where(email: collection_config['depositor_email']).count > 0

      @depositor = User.where(email: collection_config['depositor_email']).first

      byebug

      # Hash of all pids
      @pids_hash = Hash.new
      create_filepath_hash(collection_config['pids'], @pids_hash)

      # Hash of all .xml objects in storage directory
      @object_hash = Hash.new
      create_filepath_hash(collection_config['objects'], @object_hash)

      # Hash of all waivers files in storage directory
      @premis_hash = Hash.new
      create_filepath_hash(collection_config['premis'], @premis_hash)

      Migrate::Services::IngestService.new(collection_config,
                                           @pids_hash,
                                           args[:mapping_file],
                                           @depositor).ingest_records
    else
      puts 'The default admin set or specified depositor does not exist'
    end

    end_time = Time.now
    puts "[#{end_time.to_s}] Completed migration of #{args[:collection]} in #{end_time-start_time} seconds"
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
end
