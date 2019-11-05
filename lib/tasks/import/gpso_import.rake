namespace :import do
    require 'fileutils'
    require 'htmlentities'
    require 'tasks/import/import_logging'
    require 'tasks/import/services/import_service'

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
          puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{increment}/#{total_items}  : Processing the item  #{filename}"
          import_log = ImportLog.new({:pid => filename, :date_imported => Time.now, :batch_id => batch_id})
          begin
            # fetch a thesis record from xml and transform to thesis work type
             
            gpso_thesis = GpsoItem.new()

            thesis_attributes = gpso_thesis.parse(node,user)

            import_service = Import::Services::ImportService.new(user,gpso_thesis,thesis_attributes)
            new_thesis = import_service.create_thesis_record
           
            new_thesis.save!
            new_thesis.identifier = [gpso_thesis.get_url_identifier(new_thesis.id)]
 
            #create sipity record
            workflow = Sipity::Workflow.joins(:permission_template)
                         .where(permission_templates: { source_id: new_thesis.admin_set_id}, active: true)
            workflow_state = Sipity::WorkflowState.where(workflow_id: workflow.first.id, name: 'deposited')
            retry_op('creating sipity entry for thesis') do
              Sipity::Entity.create!(proxy_for_global_id: new_thesis.to_global_id.to_s,
                                     workflow: workflow.first,
                                     workflow_state: workflow_state.first)
            end

            #create file sets
            import_service.add_files(@tmp_file_location)

            #add to collection
            collectionObj = Collection.find('theses')
            collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
            new_thesis.member_of_collections << collectionObj
            begin
              new_thesis.save!
            rescue StandardError => e
              puts "#{e}: #{e.class.name}"
            end

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

=begin
    def add_files(work_attributes,new_work,item,user)
         file_set = FileSet.new
         file_attributes = Hash.new
          # Singularize non-enumerable attributes
          work_attributes.each do |k,v|
            if file_set.attributes.keys.member?(k.to_s)
              if !file_set.attributes[k.to_s].respond_to?(:each) && work_attributes[k].respond_to?(:each)
                file_attributes[k] = v.first
              else
                file_attributes[k] = v
              end
            end
          end
          file_attributes[:date_created] = work_attributes['date_created']

          #create directory in tmp_file_location for the files belonging to this thesis
          FileUtils.mkpath("#{@tmp_file_location}/#{new_work.id}")

          add_a_file_set(file_attributes,new_work,item.get_thesis_filename,user) if !item.get_thesis_filename.nil?
          add_a_file_set(file_attributes,new_work,item.get_waiver_filename,user) if !item.get_waiver_filename.nil?
          add_a_file_set(file_attributes,new_work,item.get_multimedia_filename,user) if !item.get_multimedia_filename.nil?
 
          # delete the files in tmp_file_location
          FileUtils.rm_rf("#{@tmp_file_location}/#{new_work.id}")
    end

    def add_a_file_set(file_attributes,new_work,file_name,user)
          if !file_name.nil?
            file_set = nil
            case file_name
               when /CERTIFICATE/
                 file_attributes['visibility'] = 'restricted'
                 new_title = new_work.attributes['title'].first+" - license"
                 file_attributes['title'][0] = new_title
               when /MULTIMEDIA/
                 file_attributes['visibility'] = 'open'
                 new_title = new_work.attributes['title'][0] + " - supplement"
                 file_attributes['title'][0] = new_title
               else
                 file_attributes['visibility'] = 'open'
            end
            file_part_of_name = file_name.split('/').last
            file_attributes['label']=file_part_of_name
            retry_op('creating fileset') do
              file_set = FileSet.create(file_attributes)
            end
            actor = Hyrax::Actors::FileSetActor.new(file_set,user)
            actor.create_metadata(file_attributes)
            
            #fetch the file
            uploaded_file = "#{@tmp_file_location}/#{new_work.id}/#{file_part_of_name}"
            bitstream = open(file_name)
            IO.copy_stream(bitstream,uploaded_file)
            retry_op('reading file') do
              actor.create_content(Hyrax::UploadedFile.create(file: File.open(uploaded_file), user: user))
            end
            retry_op('attaching file to thesis') do
              actor.attach_to_work(new_work,file_attributes)
            end
          end
    end

    def create_thesis_record(work_attributes,user) # see lib/tasks/migration/services/migrate_service.rb work_record()
       resource = Thesis.new
       resource.depositor = user.id
       resource.save

       # Singularize non-enumerable attributes
       work_attributes.each do |k,v|
         if resource.attributes.keys.member?(k.to_s) && !resource.attributes[k.to_s].respond_to?(:each) && work_attributes[k].respond_to?(:each)
            work_attributes[k] = v.first
         else
            work_attributes[k] = v
         end
       end
   
       # Only keep attributes which apply to the given work type
       work_attributes.select {|k,v| k.ends_with? '_attributes'}.each do |k,v|
         if !resource.respond_to?(k.to_s+'=')
            work_attributes.delete(k.split('s_')[0]+'_display')
            work_attributes.delete(k)
         end
       end
       resource.attributes = work_attributes.reject{|k,v| !resource.attributes.keys.member?(k.to_s) unless k.ends_with? '_attributes'}

       resource.visibility = work_attributes['visibility']
       resource.admin_set_id = work_attributes['admin_set_id']
       resource
    end
=end

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
