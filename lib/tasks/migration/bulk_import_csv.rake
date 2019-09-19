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
    desc 'Migrate a Digitool objects with a PID and its related items eg: bundle exec rake migration:batch_import[csvfile, batch_size]'
    task :bulk_import_csv, [:csv_file, :batch_size, :start_pos, :total] => :environment do |t, args|
      args.with_defaults(:start_pos => 0, :batch_size => 5, :total => 0)
      user_email = ENV['DEFAULT_DEPOSITOR_EMAIL'].tr('"','')

      # slice length
      batch_size =  (args[:batch_size] || 5).to_i

      # start position (number) from csv array
      start_pos =  (args[:start_pos] || 0).to_i

      # start position (number) from csv array
      total =  (args[:total] || 0).to_i

      # Lets create a batch no
      @depositor = User.where(email: user_email).first
      batch = Batch.new({:no => total, :name => args[:csv_file], :started => Time.now, :finished => Time.now, user: @depositor})
      batch.save!
      # start processing
      process_import_csv(batch.id, args[:csv_file], start_pos, batch_size, total, @depositor)

      batch.finished = Time.now
      batch.save!

      # Email error report
      send_error_report(batch, @depositor)


    end

    # Not completed yet!
    def send_error_report(batch, user)
      # Find all items that are part of a given batch
      ImportMailer.import_email(user,batch)

    end

    def process_import_csv(batch_id, csv_file, start_pos, batch_no, total, user)
      admin_set = ENV['DEFAULT_ADMIN_SET'].tr('"', '')

      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      logger = ActiveSupport::Logger.new("log/bulk-import-csv-#{datetime_today}.log")
      logger.info "Task started at #{start_time}"

      @pid_list = File.read("#{Rails.root}/#{csv_file}").strip.split(",")
      # Lets clean the csv file because of the quotes
      @pids = @pid_list.map do | item | item.gsub!(/\A"|"\Z/, '') end


      # The default admin set and designated depositor must exist before running this script
      if AdminSet.where(title: admin_set).count != 0
        # lets chunck the job

        # find out the total we need to ingest
        amount_to_import = total === 0 ?  @pids.count : total


        logger.info "Starting to import #{amount_to_import} items from position: #{start_pos}"
        puts "Starting to import #{amount_to_import} items from position: #{start_pos}"
        @pids[start_pos, amount_to_import].each_slice(batch_no) do | lists |

          successes = 0
          errors = 0
          created_works = []
          lists.each do |item|

            work_log = ImportLog.new({:pid => item, :date_imported => Time.now, :batch_id => batch_id})
            begin
                import_service = Migration::Services::ImportService.new({:pid => item, :admin_set => admin_set}, user, logger)

                import_rec = import_service.import
                if import_rec.present?
                  created_works << import_rec
                  work_log.attributes = import_rec
                  AddWorkToCollection.call(import_rec[:work_id],
                                           import_rec[:work_type],
                                           import_rec[:collection_id])
                  successes += 1
                  work_log.imported  = true
                end

             rescue StandardError => e
                errors += 1
                work_log.imported  = false
                work_log.error = "#{e}: #{e.class.name} "
                logger.error "Error importing #{item}: #{e}: #{e.class.name}"
            end
            work_log.save

          end
          puts "Processed #{successes} work(s), #{errors} error(s) encountered"
          logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"

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
