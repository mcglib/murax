namespace :import do
    require 'fileutils'
    require 'htmlentities'
    require 'tasks/import/import_logging'
    require 'tasks/import/services/import_service'

    desc 'Import theses and related items from GPSO. This rake task expects to find the xml file in the tmp directory. Eg: bundle exec rake import:gpso_import["xml_file.xml","batch report title"]'
    task :gpso_import, [:xml_file, :batch_name] => :environment do |t, args|
      gpso_xml = args[:xml_file]
      batch_name = args[:batch_name]
      if gpso_xml.empty?
        puts "Usage: bundle exec rake import:gpso_import['gpso-xml-file.xml','title for batch report']"
        puts "       The task expects to file the xml file in the tmp directory"
        exit
      end

      # set up import variables
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      user_email = ENV['DEFAULT_DEPOSITOR_EMAIL'].tr('"','')
      @depositor = User.where(email: user_email).first
      @tmp_file_location = '/storage/www/uploads/import/files'
      admin_set = ENV['DEFAULT_ADMIN_SET'].tr('"', '')
      if AdminSet.where(title: admin_set).count == 0
         puts "No admin set found. Please create one"
         exit
      end

      begin
         theses = Nokogiri::XML(File.open('tmp/'+gpso_xml)) do |config|
            config.strict.noblanks
         end
      rescue StandardError => e
         puts e.message
         exit
      end

      if theses.errors.count > 0 
        puts "Invalid xml. Aborting import..."
        puts theses.errors
        exit
      end

      theses.remove_namespaces!

      thesis_count = theses.root.children.count

      # set up logging
      batch = Batch.new({:no => thesis_count, :name => batch_name, :started => Time.now,
                         :finished => Time.now, user: @depositor})
      batch.save!
      logger = ActiveSupport::Logger.new("log/gpso-import-batch-#{batch.id}-#{datetime_today}.log")
      logger.info "Task started at #{start_time}"

      # start processing
      process_import_gpso_theses(batch.id, theses, @depositor, logger)

      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished processing #{thesis_count} theses in #{duration} minutes"
      log.info "Task finished at #{end_time} and lasted #{duration} minutes."


      # update the batch that its finished
      batch.finished = Time.now
      batch.save!

      # Email error report
      send_error_report(batch, @depositor)
    end


    #methods
    def process_import_gpso_theses(batch_id, theses, user, logger)
      amount_to_import = theses.root.children.count
      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

      logger.info "Starting to import #{amount_to_import} theses."
      puts "Starting to import #{amount_to_import} theses."

      successes = 0
      errors = 0
      total_items = amount_to_import
      increment=0
      theses.root.children.each do |node|
        if node.name == 'record'
          increment+=1
          filename = node.xpath('localfilename').first.text.split('/').last.strip
          m = filename.match(/[A-Z]+_[0-9]{4,4}_([0-9]+)_.*.pdf/)
          m ? student_id = m[1] : student_id = '000000000'
          puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{increment}/#{total_items}  : Processing the item  #{filename}"
          import_log = ImportLog.new({:pid => filename, :date_imported => Time.now, :batch_id => batch_id})
          begin
            # fetch a thesis record from xml and transform to thesis work type

            gpso_thesis = GpsoItem.new()

            thesis_attributes = gpso_thesis.parse(node,user)

            new_work_type_as_string = 'Thesis'
            import_service = Import::Services::ImportService.new(user,gpso_thesis,thesis_attributes,new_work_type_as_string)
            new_thesis = import_service.create_a_work_record
            new_thesis.save! 
            
            new_thesis['identifier'] = [gpso_thesis.get_url_identifier(new_thesis.id)]
            new_thesis.save!
 
            #create sipity record
            workflow = Sipity::Workflow.joins(:permission_template)
                         .where(permission_templates: { source_id: new_thesis.admin_set_id}, active: true)
            workflow_state = Sipity::WorkflowState.where(workflow_id: workflow.first.id, name: 'deposited')
            retry_op('creating sipity entry for thesis') do
              Sipity::Entity.create!(proxy_for_global_id: new_thesis.to_global_id.to_s,
                                     workflow: workflow.first,
                                     workflow_state: workflow_state.first)
            end


	    #create directory in tmp_file_location for the files belonging to this thesis
	    FileUtils.mkpath("#{@tmp_file_location}/#{new_thesis.id}")

            #add files
            file_attributes = import_service.create_a_file_record
            success = import_service.add_a_thesis_file_set(file_attributes,gpso_thesis.get_thesis_filename,@tmp_file_location) if !gpso_thesis.get_thesis_filename.nil?
            raise StandardError.new "Error reading or writing thesis file #{gpso_thesis.get_thesis_filename}" if !success
            success = import_service.add_a_thesis_file_set(file_attributes,gpso_thesis.get_waiver_filename,@tmp_file_location) if !gpso_thesis.get_waiver_filename.nil?
            raise StandardError.new "Error reading or writing waiver file #{gpso_thesis.get_waiver_filename}" if !success
            success = import_service.add_a_thesis_file_set(file_attributes,gpso_thesis.get_multimedia_filename,@tmp_file_location) if !gpso_thesis.get_multimedia_filename.nil?
            raise StandardError.new "Error reading or writing multimedia file #{gpso_thesis.get_multimedia_filename}" if !success

            # delete the files in tmp_file_location
            FileUtils.rm_rf("#{@tmp_file_location}/#{new_thesis.id}")

            #add to collection
            collectionObj = Collection.find('theses')
            collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
            new_thesis.member_of_collections << collectionObj
            begin
              new_thesis.save!
            rescue StandardError => e
              puts "#{e}: #{e.class.name}"
            end

            import_record={
                work_id: new_thesis.id,
                collection_id: 'theses',
                digitool_collection_code: 'N/A',
                pid: student_id,
                title: new_thesis.title.first, work_type: 'Thesis', raw_xml: node.to_s
            }
            import_log.attributes = import_record

            logger.info("added #{filename}")
            successes += 1
            import_log.imported = true

          rescue StandardError => e
            errors += 1
            import_record={
               work_id: new_thesis.id,
               collection_id: 'theses',
               digitool_collection_code: 'N/A',
               pid: student_id,
               title: new_thesis.title.first,
               work_type: 'Thesis',
               raw_xml: node.to_s
            }
            import_log.attributes = import_record
            import_log.imported  = false
            import_log.error = "#{e}: #{e.class.name} "
            logger.error "Error importing #{filename} or related data: #{e}: #{e.class.name}"
          end
        end
        import_log.save
      end
      puts "Imported #{successes} work(s), #{errors} error(s) encountered"
      logger.info "Imported #{successes} work(s), #{errors} error(s) encountered"
      theses
    end

    def send_error_report(batch, user)
      @errors = batch.import_log.not_imported
      # Find all items that are part of a given batch
      ImportMailer.import_email(user,batch).deliver
    end


    private

    def retry_op(message = nil)
      begin
        retries ||= 0
        yield
      rescue Exception => e
        puts "[#{Time.now.to_s}] #{e}"
        puts e.backtrace.map{ |x| x.match(/^\/net\/deploy\/ir\/test\/releases.*/)}.compact
        puts message unless message.nil?
        sleep(5)
        retry if (retries += 1) < 2
        abort("[#{Time.now}] could not recover; aborting operation")
      end
    end


end
