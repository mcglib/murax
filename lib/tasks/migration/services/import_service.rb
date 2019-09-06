module Migration
  module Services
    require 'fileutils'
    require 'htmlentities'
    require 'csv'
    require 'yaml'

    require 'tasks/migration/migration_logging'
    require 'tasks/migration/migration_constants'
    require 'tasks/migrate/services/id_mapper'
    require 'tasks/migrate/services/metadata_parser'
    require 'tasks/migration_helper'

    class ImportService
      attr_accessor :pid, :depositor, :logger, :admin_set
      def initialize(import_params, depositor, logger)
        @depositor = depositor
        @pid = import_params[:pid]
        @admin_set = import_params[:admin_set]
        @logger = logger
      end

      def import(count: 0)
        import_record = nil

        begin
          item = DigitoolItem.new({ :pid => @pid}) if @pid.present?
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
          migration_config = MigrationHelper::get_migration_config(collection_id) if collection_id.present?

          # lets create the tmp file location if it does not exist
          FileUtils::mkdir_p migration_config['tmp_file_location'] if migration_config.present?


          # empty the item
          item = nil

          migrate_service = Migration::Services::MigrateService.new(migration_config,
                                               @depositor)
          work_id = migrate_service.import_records([@pid], @logger, work_type)

          # Get the title
          work = work_type.constantize.find(work_id.first)

          # Return the following info, work_id, collection_id, title, pid, work_type
          import_record = {work_id: work.id,
                           collection_id: collection_id,
                           digitool_collection_code: lc_code,
                           pid: @pid,
                           title: work.title.first, work_type: work_type }
          # Maybe we can add the import_record to db

        rescue StandardError => e
          #raise e if count > 
          #count += 1
          @logger.info "Failed importing #{@pid} times. Error: #{e.message}: #{e.class.name}"
          #return import(count: count)
        end

        import_record

      end

    end
  end

end
