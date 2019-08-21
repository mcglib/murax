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
    desc 'Migrate a Digitool objects with a PID and its related items eg: bundle exec rake migrate:digitool_item[csvfile]'
    task :batch_import, [:csv_file] => :environment do |t, args|

      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

      start_time = Time.now
      log = ActiveSupport::Logger.new("log/digitool-import-#{start_time}.log")
      log.info "Task started at #{start_time}"

      @pid_list = File.read("#{Rails.root}/#{args[:csv_file]}").strip.split(",")
      # Lets clean the csv file because of the quotes
      @pids = @pid_list.map do | item | item.gsub!(/\A"|"\Z/, '') end

      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
          User.where(email: ENV['DEFAULT_DEPOSITOR_EMAIL']).count > 0
        # lets chunck the job
        @pids.each_slice(5) do | lists |

          puts "Object count:  #{lists.count.to_s}"
          lists.each do |item|
            import_service = Migration::Services::ImportService.new(item)
            created_work_ids << import_service.import
          end
          
          #puts "Adding the following workids: #{created_work_ids.split(",")} to the collection #{migration_config['samvera_collection_id']}"
          #migrate_service.add_works_to_collection(created_work_ids, migration_config['samvera_collection_id'])
        end
      else
        puts 'The default admin set or specified depositor does not exist'
      end




    end

  end
