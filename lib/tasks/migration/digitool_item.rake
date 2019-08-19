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
    # bundle exec rake migrate:digitool_item -- -p 12007 -c 'thesis'
    desc 'Migrate a Digitool object with a PID and its related items eg: bundle exec rake migrate:digitool_item[pid,localcollectioncode,itemtype, collection-id]'
    task :digitool_item, [:pid,:localcollectioncode,:itemtype, :collectionid] => :environment do |t, args|
      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!
  
      puts "[#{start_time.to_s}] Start migration of pid item #{pid} to the collection #{collectionid}"
  
      item  = DigitoolItem.new({"pid" => pid})
      migration_config = get_migration_config(collection)
      depositor_email = migration_config['depositor_email']
      # make sure you have a depositor
      @depositor = User.where(email: depositor_email).first
      if @depositor.present?
  
        # 3. Import the metadata
        Migrate::Services::MigrateService.new(migration_config,
                                              item,
                                              @depositor, @temp).import
        # 4. Add the collection to the item
        
      else
        puts 'The default admin set or specified depositor does not exist'
      end
  
    end 
 
    private
 
      def read_file_csv(filename, array)
        array = data.split(",")
      end
  end
  
