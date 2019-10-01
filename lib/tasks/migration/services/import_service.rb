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

          # So we need to check if the item is an 
          # archive. If it is, we skip ingesting 
          puts "Skipping adding this item #{item.pid} as its not the main_view.its a #{item.get_usage_type}" unless item.is_main_view?

          raise StandardError.new "this item #{item.pid} as its not the main_view.its a #{item.get_usage_type}" unless item.is_main_view?

          raise StandardError.new "this item #{item.pid} is a potential duplicate with no main object. it's a #{item.get_usage_type}" if item.is_duplicated?

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
          xml = item.raw_xml
          item = nil

          migrate_service = Migration::Services::MigrateService.new(migration_config,
                                               @depositor)
          work_id = migrate_service.import_records([@pid], @logger, work_type)

          # Get the title
          work = work_type.constantize.find(work_id.first)

          # Return the following info, work_id, collection_id, title, pid, work_type
          import_record = {work_id: work.id,
                           collection_id: migration_config['samvera_collection_id'],
                           digitool_collection_code: lc_code,
                           pid: @pid,
                           title: work.title.first, work_type: work_type, raw_xml: xml.to_s }

        rescue StandardError => e
          #raise e if count > 
          #count += 1
          @logger.error "Failed importing #{@pid}. Error: #{e.message}: #{e.class.name}"
          #raise e if count > 1
          #return import(count: count)
        end

        import_record

      end

    end
  end

end
