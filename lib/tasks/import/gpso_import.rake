namespace :import do
    require 'fileutils'
    require 'htmlentities'
    require 'csv'
    require 'yaml'
    # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
    require 'tasks/import/import_logging'
    #require 'tasks/migration/migration_constants'
    #require "tasks/migration/services/migrate_service"
    #require 'tasks/migration/services/metadata_parser'
    #require 'tasks/migration/services/import_service'
    #require 'tasks/migration_helper'
    require 'byebug'

    desc 'Import theses and related items from GPSO. This rake task expects to find the xml file in the tmp directory. Eg: bundle exec rake import:gpso_import["xml_file.xml"]'
    task :gpso_import, [:xml_file] => :environment do |t, args|
      gpso_xml = args[:xml_file]
      if gpso_xml.empty?
        puts "Usage: bundle exec rake import:gpso_import['gpso-xml-file.xml']"
        puts "       The task expects to file the xml file in the tmp directory"
        exit
      end

      # set up import variables
      start_time = Time.now
      datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      user_email = ENV['DEFAULT_DEPOSITOR_EMAIL'].tr('"','')
      @depositor = User.where(email: user_email).first
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
      batch = Batch.new({:no => thesis_count, :name => 'gpso_import', :started => Time.now,
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
      #send_error_report(batch, @depositor)
    end


    #methods
    def process_import_gpso_theses(batch_id, theses, user, logger)
      amount_to_import = theses.root.children.count
      require "#{Rails.root}/app/services/find_or_create_collection" # <-- HERE!

      logger.info "Starting to import #{amount_to_import} items."
      puts "Starting to import #{amount_to_import} items."

      successes = 0
      errors = 0
      total_items = amount_to_import
      increment=0
      theses.root.children.each do |node|
        if node.name == 'record'
          increment+=1
          filename = node.xpath('localfilename').first.text.split('/').last.strip
          puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{increment}/#{total_items}  : Processing the item  #{filename}"
          import_log = ImportLog.new({:pid => filename, :date_imported => Time.now, :batch_id => batch_id})
          begin
            # fetch a thesis record from xml and transform to thesis work type
            
            item = GpsoItem.new()

            work_attributes = item.parse(node,user)
            byebug

            new_work = create_thesis_record(work_attributes,user)
            new_work.save!
            new_work.identifier = [item.get_url_identifier(new_work.id)]
 
            #create sipity record
            workflow = Sipity::Workflow.joins(:permission_template)
                         .where(permission_templates: { source_id: new_work.admin_set_id}, active: true)
            workflow_state = Sipity::WorkflowState.where(workflow_id: workflow.first.id, name: 'deposited')
            retry_op('creating sipity entry for thesis') do
              Sipity::Entity.create!(proxy_for_global_id: new_work.to_global_id.to_s,
                                     workflow: workflow.first,
                                     workflow_state: workflow_state.first)
            end

            #create file set
            create_fileset(work_attributes,new_work,item)

            #add to collection
            collectionObj = Collection.find('theses')
            collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
            new_work.member_of_collections << collectionObj
            new_work.save!

            logger.info("added #{filename}")
            successes += 1

          rescue StandardError => e
            errors += 1
            import_log.imported  = false
            import_log.error = "#{e}: #{e.class.name} "
            logger.error "Error importing #{filename}: #{e}: #{e.class.name}"
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

    def create_fileset(work_attributes,new_work,item)
         # TODO
    end

    def create_thesis_record(work_attributes,user) # see lib/tasks/migration/services/migrate_service.rb work_record()
       resource = Thesis.new
       resource.depositor = user.id
       resource.save
       work_attributes.each do |k,v|
          resource.attributes[k.to_s]=v if resource.has_attribute?(k.to_s)
       end
       resource.visibility = work_attributes['visibility']
       resource.admin_set_id = work_attributes['admin_set_id']
       resource
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
