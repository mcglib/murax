module Migrate
  class ImportRecord
    # Must include the email address of a valid user in order to ingest files
    @env_default_admin_set = 'default'
    @pid = nil

    def self.call(pid, batch_id, depositor, logger)
      work_id = nil
      puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{index}/#{total_items}  : Processing the item  #{pid}"
      import_log = ImportLog.new({:pid => pid, :date_imported => Time.now, :batch_id => batch_id})
      begin
        Migrate::ImportService(pid,depositor)
        begin
            import_service = Migration::Services::ImportService.new({:pid => pid, :admin_set => admin_set}, user, logger)
            import_rec = import_service.import
            if import_rec[:error].nil?
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
            logger.error "Error importing #{pid}: #{e}: #{e.class.name}"
        end
        import_log.save
      rescue => e
        puts "Error occured creating the role for #{role_params[:name]}: Error: #{e} -  #{@form.errors}"
        work_id = false
      end

     work_id

    end
  end
end
