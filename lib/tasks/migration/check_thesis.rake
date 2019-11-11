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

    # bundle exec rake migraton:digitool_item -- -p 12007 -c 'thesis'
    desc 'Verify that the thesis items have all been properly imported. Remove duplicates if any eg: bundle exec rake migration:check_thesis[csvfile]'
    task :check_thesis, [:csv_file, :batch_size, :start_pos, :total] => :environment do |t, args|


      check_thesis(csvfile)
      # update the batch that its finished
      batch.finished = Time.now
      batch.save!

      # Email error report
      send_error_report(batch, @depositor)


    end

    # Not completed yet!
    def send_error_report(batch, user)
      # Find all items that are part of a given batch
      ImportMailer.import_email(user,batch).deliver
    end

    def check_thesis(csv_file)
      admin_set = ENV['DEFAULT_ADMIN_SET'].tr('"', '')

      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      logger = ActiveSupport::Logger.new("log/bulk-import-batch-#{batch_id}-#{datetime_today}.log")
      logger.info "Task started at #{start_time}"

      if csv_file.include? "ethesis"
        @pid_list = File.read("#{Rails.root}/#{csv_file}").strip.split("\n")
        @pids = @pid_list
      else
        @pid_list = File.read("#{Rails.root}/#{csv_file}").strip.split(",")
        @pids = @pid_list.map do | item | item.gsub!(/\A"|"\Z/, '') end
      end
      # Lets clean the csv file because of the quotes


      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: admin_set).count != 0
        # lets chunck the job

        # find out the total we need to ingest
        amount_to_import = total === 0 ?  @pids.count : total


        logger.info "Starting to import #{amount_to_import} items from position: #{start_pos}"
        puts "Starting to import #{amount_to_import} items from position: #{start_pos}"
        successes = 0
        errors = 0
        total_items = @pids[start_pos, amount_to_import].count
        @pids[start_pos, amount_to_import].each_with_index do |item, index |

          #created_works = []
            puts "#{index}/#{total_items}:  #{Time.now.to_s}: Processing the item  #{item}"
            import_log = ImportLog.new({:pid => item, :date_imported => Time.now, :batch_id => batch_id})
            begin
                import_service = Migration::Services::ImportService.new({:pid => item, :admin_set => admin_set}, user, logger)
                import_rec = import_service.import
                if import_rec[:error].nil?
                  #created_works << import_rec
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
                logger.error "Error importing #{item}: #{e}: #{e.class.name}"
            end
            import_log.save


          # Group the works by collection_id and then add to collection
          #created_works.group_by { |d| d[:collection_id] }.each do | collect_id, works |
          #  puts "Adding the following workids: #{works.pluck(:work_id).split(",")} to the collection #{collect_id}"
          #  logger.info "Adding the following workids: #{works.pluck(:work_id).split(",")} to the collection #{collect_id}"
          #  AddWorksToCollection.call( works.pluck(:work_id, :work_type),collect_id)
          #  # lets add the record to the import log after adding to the collection
          #  puts "Creating a report log for the ingested works"
          #  logger.info "Creating a report log for the ingested works"
          #  AddWorksToImportLog.call( works, collect_id)
          #end
          #created_works.pluck(:work_id)
        end
        puts "Processed #{successes} work(s), #{errors} error(s) encountered"
        logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"
      else
        puts 'The default admin set or specified depositor does not exist'
      end
      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  migration of #{amount_to_import} in #{duration} minutes"
      logger.info "Task finished at #{end_time} and lasted #{duration} minutes."
      logger.close

      # Send email of what has been completed
      # Send email of the errors that occured
    end
  end
