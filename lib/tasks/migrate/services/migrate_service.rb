module Migrate
  module Services
    require 'tasks/migrate/services/id_mapper'
    require 'tasks/migrate/services/metadata_parser'
    require 'tasks/migration_helper'

    attr_accessor :pid_list, :created_work_ids
    class MigrateService

      def initialize(config, depositor)
        @work_type = config['work_type']
        @depositor = depositor
        @tmp_file_location = config['tmp_file_location']
        @config = config
        @created_work_ids = []
      end
      def import_records(pid_list, log)
        STDOUT.sync = true
        if pid_list.empty?
          puts "The pid list is empty."
          log.info "The pid list is empty. No importing will be done"
          return
        end

        @pid_list = pid_list
        pid_count = @pid_list.count
        log.info "Object count:  #{@pid_list.count.to_s}"
        
        # get array of record pids
        #collection_pids = MigrationHelper.get_collection_pids(@collection_ids_file)

        @pid_list[0..10].each.with_index do | pid, index |
          log.info "#{index}/#{pid_count} - Importing  #{pid}"
          item = DigitoolItem.new({"pid" => pid})

          log.info "The work #{item.pid} does not have any metadata. skipping." unless item.has_metadata?
          puts "The work #{item.pid} does not have any metadata. skipping." unless item.has_metadata?
          next unless item.has_metadata?
          
          log.info "This item #{item.pid} has a main work and its not a main work." unless item.is_main_view?
          puts "Skipping adding this item #{item.pid} as its not the main_view." unless item.is_main_view?
          next unless item.is_main_view?

          # check if the item has been added already
          # maybe we can add this check later
          # Create new work record and save
          puts item.pid
          new_work = create_work(item)
          log.info "The work has been created for #{item.title} as a #{@work_type}" if new_work.present?
          # Save the work id to the created_works array
          @created_work_ids << new_work.id if new_work.present?

        end

         # Now we need to add the pids to the collection
         add_works_to_collection(@created_work_ids, @config['collection'])
         
         @created_work_ids

      end

      def add_works_to_collection(work_ids, collection_name)
        attached = true

        # Get the collection
        user_collection_type = Hyrax::CollectionType.where(title: 'User Collection').first.gid
        collectionObj = Collection.find(collection_name)
        collectionObj.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX

        work_ids.each do |wkid|
           attached = attach_work_to_collection(wkid, collectionObj)
        end

        attached
      
      end

      def attach_work_to_collection(work_id, collection)
          attached = true
          # Get the work
          work = (@work_type.singularize.classify.constantize).find(work_id)

          begin
            work.member_of_collections << collection
            work.save!
          rescue  StandardError => e
            attached = false
            puts "The work #{work_id} could not be attached to the collection #{collection.id}. See #{e}"
            
          end
          attached
      end

      def create_fileset(parent: nil, resource: nil, file: nil)
        file_set = nil
        MigrationHelper.retry_operation('creating fileset') do
          file_set = FileSet.create(resource)
        end

        actor = Hyrax::Actors::FileSetActor.new(file_set, @depositor)
        actor.create_metadata(resource)

        renamed_file = "#{@tmp_file_location}/#{parent.id}/#{resource['label']}"
        FileUtils.mkpath("#{@tmp_file_location}/#{parent.id}")
        FileUtils.cp(file, renamed_file)

        MigrationHelper.retry_operation('creating fileset') do
          actor.create_content(Hyrax::UploadedFile.create(file: File.open(renamed_file), user: @depositor))
        end

        MigrationHelper.retry_operation('creating fileset') do
          actor.attach_to_work(parent, resource)
        end

        File.delete(renamed_file) if File.exist?(renamed_file)

        file_set
      end


      private
        # FileSets can include any metadata listed in BasicMetadata file
        def file_record(work_attributes)
          file_set = FileSet.new
          file_attributes = Hash.new

          #file attr
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
          file_attributes[:visibility] = work_attributes['visibility']
          unless work_attributes['embargo_release_date'].blank?
            file_attributes[:embargo_release_date] = work_attributes['embargo_release_date']
            file_attributes[:visibility_during_embargo] = work_attributes['visibility_during_embargo']
            file_attributes[:visibility_after_embargo] = work_attributes['visibility_after_embargo']
          end

          file_attributes
        end

        def create_work(item)
          

          log.info "The work #{item.pid} does not have any metadata. skipping." unless item.has_metadata?
          puts "The work #{item.pid} does not have any metadata. skipping." unless item.has_metadata?
          return unless item.has_metadata?
          
          parsed_data = Migrate::Services::MetadataParser.new(item.get_metadata,
                                                              @depositor,
                                                              @config).parse
          begin
            work_attributes = parsed_data[:work_attributes]
            work_attributes["relation"] << "pid: #{item.pid}"

            new_work = work_record(work_attributes)
            new_work.save!
            

            # update the identifier and the pid

            #update the identifier
            new_work.identifier = "https://#{ENV["RAILS_HOST"]}/concerns/theses/#{new_work.id}"

            # Create sipity record
            workflow = Sipity::Workflow.joins(:permission_template)
                           .where(permission_templates: { source_id: new_work.admin_set_id }, active: true)
            workflow_state = Sipity::WorkflowState.where(workflow_id: workflow.first.id, name: 'deposited')
            MigrationHelper.retry_operation('creating sipity entity for work') do
              Sipity::Entity.create!(proxy_for_global_id: new_work.to_global_id.to_s,
                                     workflow: workflow.first,
                                     workflow_state: workflow_state.first)
            end

            # We add the main file to the work
            fileset = add_main_file(item, work_attributes, new_work)
            puts "The work #{item.pid} does not have a main file set.Check for errors"  if fileset.nil?
            log.info "The work #{item.pid} does not have a file set." if fileset.nil?
            
            # now we fetch the related pid files
            if item.has_related_pids?
              add_related_files(item, work_attributes, work) 
            end



            # resave
            new_work.save!
          rescue Exception => e
            puts "The item #{item.title} with pid id: #{item.pid} could not be saved as a work. #{e}"
            log.info "The item #{item.title} with pid id: #{item.pid} could not be saved as a work. #{e}"
            log.info "We set up them the bomb."
          end


          new_work
          
        end

        def add_related_files(item, work_attributes, work) 
        

          suggested_types = ['VIEW', 'VIEW_MAIN', 'ARCHIVE']
          file_list = []
          # First batch of pids
          item.get_related_pids.each do | rel_pid, item_type |
            if suggested_types.include?(item_type)
                 # We downlond the file to a temporary location
                 FileUtils.mkpath("#{@tmp_file_location}/#{rel_pid}")
                 downloaded_file = MigrationHelper.download_digitool_file_by_pid(rel_pid, "#{@tmp_file_location}/#{rel_pid}" )
                 file_list << {pid: rel_pid, type: item_type, file_path: downloaded_file['path'], file_name: downloaded_file['name']}

            end
          end
          attached = false
          file_list.each do |fitem|
            # We add the related files if any
            attached = add_related_file_to_work(fitem[:file_path], work_attributes, new_work, hidden)
          end
          file_list
        end

        def add_related_file_to_work(file_path, work_attributes, new_work, hidden)
            work_attributes['label'] = file_name
            fileset_attrs = file_record(work_attributes)
            fileset = create_fileset(parent: new_work, resource: fileset_attrs, file: file_path)
        end

        def add_main_file(item, work_attributes, new_work)
          # now we need to get the main file set and add it to the file
          file_path = item.download_main_pdf_file(@tmp_file_location)
          if (file_path.present?)
            file_name = item.file_info['file_name']

            work_attributes['label'] = file_name
            fileset_attrs = file_record(work_attributes)
            fileset = create_fileset(parent: new_work, resource: fileset_attrs, file: file_path)

          end

          fileset
        
        end

        def work_record(work_attributes)
          if !@child_work_type.blank? && !work_attributes['cdr_model_type'].blank? &&
              !(work_attributes['cdr_model_type'].include? 'info:fedora/cdr-model:AggregateWork')
            resource = @child_work_type.singularize.classify.constantize.new
          else
            resource = @work_type.singularize.classify.constantize.new
          end
          resource.depositor = @depositor.id
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
          unless work_attributes['embargo_release_date'].blank?
            resource.embargo_release_date = work_attributes['embargo_release_date']
            resource.visibility_during_embargo = work_attributes['visibility_during_embargo']
            resource.visibility_after_embargo = work_attributes['visibility_after_embargo']
          end
          resource.admin_set_id = work_attributes['admin_set_id']
          if !@collection_name.blank? && !work_attributes['member_of_collections'].first.blank?
            resource.member_of_collections = work_attributes['member_of_collections']
          end

          resource
        end


        def attach_children
          @parent_hash.each do |parent_id, children|
            hyrax_id = @mappings[parent_id]
            parent = @work_type.singularize.classify.constantize.find(hyrax_id)
            children.each do |child|
              if @mappings[child]
                parent.ordered_members << ActiveFedora::Base.find(@mappings[child])
                parent.members << ActiveFedora::Base.find(@mappings[child])
              end
            end
            parent.save!
          end
        end
    end
  end
end
