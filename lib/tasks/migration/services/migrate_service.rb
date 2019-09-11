module Migration
  module Services
    require 'tasks/migrate/services/id_mapper'
    require 'tasks/migrate/services/metadata_parser'
    require 'tasks/migration_helper'

    class MigrateService
      attr_accessor :pid_list, :created_work_ids, :config, :depositor, :work_type
      def initialize(config, depositor)
        @work_type = config['work_type']
        @depositor = depositor
        @tmp_file_location = config['tmp_file_location']
        @config = config
        @created_work_ids = []
      end

      def import_records(pid_list, log, work_type = nil)
        STDOUT.sync = true
        if pid_list.empty?
          puts "The pid list is empty."
          log.info "The pid list is empty. No importing will be done"
          return
        end

        pid_count = pid_list.count.to_s
        log.info "Object count:  #{pid_count}"
        # get array of record pids
        #collection_pids = MigrationHelper.get_collection_pids(@collection_ids_file)

        workid_list = []
        pid_list.each.with_index do | pid, index |

          puts "#{Time.now.to_s}: Processing the item  #{pid}"
          log.info "#{index}/#{pid_count} - Importing  #{pid}"

          new_work = self.import_record(pid, log, work_type, index)
          @created_work_ids << new_work.id if new_work.present?

          workid_list << new_work.id if new_work.present?

        end

        workid_list
      end

      def import_record(pid, log, work_type = nil, index = 1)

        @work_type = work_type if work_type.present?
        new_work = nil
        new_work = process_pid(pid, index)
        new_work
      end


      def process_pid(pid, index)
        # inistanciate the class_name based on the worktype passed

        class_name = "Digitool::" + @work_type + "Item"
        item = class_name.constantize.new({"pid" => pid,
                                          "work_type" => @work_type,
        })


        log.info "The work #{item.pid} does not have any metadata. skipping." unless item.has_metadata?
        puts "The work #{item.pid} does not have any metadata. skipping." unless item.has_metadata?

        log.info "This item #{item.pid} has a main work and its not a main work." unless item.is_main_view?
        puts "Skipping adding this item #{item.pid} as its not the main_view." unless item.is_main_view?

        # check if the item has been added already
        # maybe we can add this check later
        # Create new work record and save
        parsed_data = item.parse(@config, @depositor)

        begin
           work_attributes = parsed_data[:work_attributes]

          new_work = work_record(work_attributes)
          new_work.save!

          #update the identifier if we need one for the work_type
          if new_work.instance_of? Thesis
            #new_work.identifier ||= []
            #new_work.identifier << item.get_url_identifier(new_work.id)
            new_work.identifier = [item.get_url_identifier(new_work.id)]
            new_work.save
          end

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
          fileset = add_main_file(item.pid, work_attributes, new_work)
          puts "The work #{pid} does not have a main file set.Check for errors"  if fileset.nil?
          log.info "The work #{pid} does not have a file set." if fileset.nil?

          # now we fetch the related pid files
          if item.has_related_pids?
            add_related_files(item, work_attributes,new_work)
          end

          # resave
          new_work.save!
          log.info "The work has been created for #{item.title} as a #{@work_type}" if new_work.present?
        rescue StandardError => e
          puts "The item #{item.title} with pid id: #{item.pid} could not be saved as a work. #{e}, #{e.class.name}, #{e.backtrace}"
          log.info "The item #{item.title} with pid id: #{item.pid} could not be saved as a work. #{e}"
          new_work = false
        end

        new_work

      end

      def add_works_to_collection(work_ids, collection_name)
        attached = true

        # Get the collection
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
          work = (@work_type.singularize.classify.constantize).find(work_id).first

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

        MigrationHelper.retry_operation('creating the content') do
          actor.create_content(Hyrax::UploadedFile.create(file: File.open(renamed_file), user: @depositor))
        end

        MigrationHelper.retry_operation('attaching the work to parent') do
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


        end

        def add_related_files(item, work_attributes, work) 


          suggested_types = ['VIEW', 'VIEW_MAIN', 'ARCHIVE']
          file_list = []
          # First batch of pids
          item.get_related_pids.each do | rel_pid, item_type |
            if suggested_types.include?(item_type)
                 # We downlond the file to a temporary location
                 FileUtils.mkpath("#{@tmp_file_location}/#{rel_pid}")
                 file_list << MigrationHelper.download_digitool_file_by_pid(rel_pid, "#{@tmp_file_location}/#{rel_pid}" )
            end
          end
          file_list.each do |fitem|
            # We add the related files if any
            attached = add_related_file_to_work(fitem, work_attributes, work)
          end
          file_list
        end

        def add_related_file_to_work(file_info, work_attributes, new_work)
          fileset = nil
          if (file_info[:path].present?)
            work_attributes['label'] = file_info[:name]
            work_attributes['title'] = [file_info[:name]]
            work_attributes['visibility'] = file_info[:visibility]
            fileset_attrs = file_record(work_attributes)
            fileset = create_fileset(parent: new_work, resource: fileset_attrs, file: file_info[:path])
          end
          fileset
        end

        def add_main_file(item_pid, work_attributes, new_work)

          fileset = nil
          FileUtils.mkpath("#{@tmp_file_location}/#{item_pid}")
          file_info =  MigrationHelper.download_digitool_file_by_pid(item_pid, "#{@tmp_file_location}/#{item_pid}" )
          fileset = add_related_file_to_work(file_info, work_attributes, new_work)

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
