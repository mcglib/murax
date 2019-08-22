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
    # bundle exec rake migrate:digitool_item -- -p 12007 -c 'thesis'
    desc 'Migrate a Digitool objects with a PID and its related items eg: bundle exec rake migrate:digitool_item[csvfile]'
    task :batch_import, [:csv_file] => :environment do |t, args|

      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

      start_time = Time.now
      logger = ActiveSupport::Logger.new("log/digitool-import-#{start_time}.log")
      logger.info "Task started at #{start_time}"

      @pid_list = File.read("#{Rails.root}/#{args[:csv_file]}").strip.split(",")
      # Lets clean the csv file because of the quotes
      @pids = @pid_list.map do | item | item.gsub!(/\A"|"\Z/, '') end

      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: ENV['DEFAULT_ADMIN_SET']).count != 0 &&
          User.where(email: ENV['DEFAULT_DEPOSITOR_EMAIL']).count > 0
        # lets chunck the job
        # Get the depositor
        @depositor = User.where(email: ENV['DEFAULT_DEPOSITOR_EMAIL']).first
        @pids.each_slice(2) do | lists |

          created_works = []
          lists.each do |item|
            logger.info "Ingesting Digitool PID: #{item}"
            import_service = Migration::Services::ImportService.new({:pid => item, :admin_set => ENV['DEFAULT_ADMIN_SET']}, @depositor, logger)

            import_rec = import_service.import
            created_works << import_rec if import_rec.present?
          end

          # Group the works by collection_id and then add to collection
          created_works.group_by { |d| d[:collection_id] }.each do | collect_id, works |
            puts "Adding the following workids: #{works.pluck(:work_id).split(",")} to the collection #{collect_id}"
            AddWorksToCollection.call( works.pluck(:work_id, :worktype),collect_id)
          end


          created_works.pluck(:work_id)
        end
      else
        puts 'The default admin set or specified depositor does not exist'
      end




    end

  end
