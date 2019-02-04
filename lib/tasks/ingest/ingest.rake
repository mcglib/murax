namespace :ingest do
  require 'fileutils'
  require 'tasks/migration/migration_logging'
  require 'htmlentities'
  require 'tasks/migration/migration_constants'
  require 'csv'
  require 'yaml'

  # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
  require "tasks/ingest/services/ingest_service"
  require "tasks/ingest/services/id_mapper"
  require 'tasks/ingest/services/metadata_parser'

  # temporary location for file download
  @temp = 'lib/tasks/ingest/tmp'
  FileUtils::mkdir_p @temp


  desc 'Create collections'
  task :create_collections => :environment do
    options = {
          config_file: 'spec/fixtures/ingest/collection_config.yml',
          collection: 'ethesis'
    }
    o = OptionParser.new
    o.banner = "Usage: rake ingest:ethesis [options]"
    o.on('-f FILENAME', '--xmlfile FILENAME') { |xmlfile|
      options[:xmlfile] = xmlfile
    }
    o.on('-c CONFIGFILE', '--config CONFIGFILE') { |config_file|
      options[:config_file] = config_file
    }
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)

  end


  desc 'Ingest  the Ethesis records from the GPSO team'
  task :ethesis =>:environment do
    options = {
          xmlfile: 'spec/fixtures/ingest/ingest.xml',
          config_file: 'spec/fixtures/ingest/config.yml',
          collection: 'ethesis'
    }
    o = OptionParser.new
    o.banner = "Usage: rake ingest:ethesis [options]"
    o.on('-f FILENAME', '--xmlfile FILENAME') { |xmlfile|
      options[:xmlfile] = xmlfile
    }
    o.on('-c CONFIGFILE', '--config CONFIGFILE') { |config_file|
      options[:config_file] = config_file
    }
    #return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)
    puts "hello #{options.inspect}"
    start_time = Time.now

    @metadata_file = File.join(Rails.root, options[:xmlfile]) if options[:xmlfile].present?
    start_time = Time.now
    puts "[#{start_time.to_s}] Start ingest of ethesis"

    config = YAML.load_file(File.join(Rails.root, options[:config_file]))
    collection_config = config[options[:collection]]
    depositor_email = collection_config['depositor_email']
    # make sure you have a depositor
    @depositor = User.where(email: depositor_email).first

    # The default admin set and designated depositor must exist before running this script
    if @depositor.present?

      @collection = FindOrCreateCollection.create(collection_config['collection'], depositor_email)
      Ingest::Services::IngestService.new(collection_config,
                                          @metadata_file,
                                           @depositor, @collection).ingest_records
    else
      puts 'The default admin set or specified depositor does not exist'
    end

    end_time = Time.now
    puts "[#{end_time.to_s}] Completed migration of #{args[:collection]} in #{end_time-start_time} seconds"

  end

  desc 'batch migrate records from CSV file with PIDs'
  task :works, [:collection, :configuration_file, :mapping_file] => :environment do |t, args|

    require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

    start_time = Time.now
    puts "[#{start_time.to_s}] Start migration of #{args[:collection]}"

    config = YAML.load_file(args[:configuration_file])
    collection_config = config[args[:collection]]


    # The default admin set and designated depositor must exist before running this script
    if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
        User.where(email: collection_config['depositor_email']).count > 0
      @depositor = User.where(email: collection_config['depositor_email']).first

      # Hash of all binaries in storage directory
      @binary_hash = Hash.new
      create_filepath_hash(collection_config['binaries'], @binary_hash)

      # Hash of all .xml objects in storage directory
      @object_hash = Hash.new
      create_filepath_hash(collection_config['objects'], @object_hash)

      # Hash of all waivers files in storage directory
      @premis_hash = Hash.new
      create_filepath_hash(collection_config['premis'], @premis_hash)

      Migrate::Services::IngestService.new(collection_config,
                                           @object_hash,
                                           @binary_hash,
                                           @premis_hash,
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
        file.each do |line|
          value = line.strip
          key = get_uuid_from_path(value)
          if !key.blank?
            hash[key] = value
          end
        end
      end
    end
end
