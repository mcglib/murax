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
      end

      def import_records(pid_list, log)
        STDOUT.sync = true
        if pid_list.empty?
          puts "The pid list is empty."
          log.info "The pid list is empty"
          return
        end

        @pid_list = pid_list
        pid_count = @pid_list.count
        log.info "Object count:  #{@pid_list.count.to_s}"
        
        # get array of record pids
        #collection_pids = MigrationHelper.get_collection_pids(@collection_ids_file)

        @pid_list[0..5].each.with_index do | pid, index |
          log.info "#{index}/#{pid_count} - Importing  #{pid}"
          item = DigitoolItem.new({"pid" => pid})


          # Create new work record and save
          new_work = create_work(item)
          puts "The work has been created for #{new_work.title} as a #{@work_type}" if new_work.present?
          log.info "The work has been created for #{new_work.title} as a #{@work_type}" if new_work.present?
          

          # Save the work id to the created_works array
          @created_work_ids.push[work.id] if work.present?
        end

        @created_work_ids

      end
      def create_fileset(parent: nil, resource: nil, file: nil)
        file_set = nil
        MigrationHelper.retry_operation('creating fileset') do
          file_set = FileSet.create(resource)
        end

        actor = Hyrax::Actors::FileSetActor.new(file_set, @depositor)
        actor.create_metadata(resource)

        renamed_file = "#{@tmp_file_location}/#{parent.id}/#{Array(resource['title']).first}"
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
          # Create new work record and save
          parsed_data = Migrate::Services::MetadataParser.new(item.metadata_hash,
                                                              @depositor,
                                                              @config).parse
          work_attributes = parsed_data[:work_attributes]
          file_work_attributes = item.file_info
          new_work = work_record(work_attributes)
          new_work.save!
          
          # Create sipity record
          workflow = Sipity::Workflow.joins(:permission_template)
                         .where(permission_templates: { source_id: new_work.admin_set_id }, active: true)
          workflow_state = Sipity::WorkflowState.where(workflow_id: workflow.first.id, name: 'deposited')
          MigrationHelper.retry_operation('creating sipity entity for work') do
            Sipity::Entity.create!(proxy_for_global_id: new_work.to_global_id.to_s,
                                   workflow: workflow.first,
                                   workflow_state: workflow_state.first)
          end



          byebug
          file_path = item.download_main_pdf_file(@tmp_file_location)
          fileset_attrs = file_record(work_attributes.merge(file_work_attributes))
          fileset = create_fileset(parent: new_work, resource: fileset_attrs, file: file_path)

          new_work.ordered_members << fileset

          # now we need to get the file set and add it to the file
          byebug
          new_work
          
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

        # FileSets can include any metadata listed in BasicMetadata file
        def file_record(work_attributes)
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
          file_attributes[:visibility] = work_attributes['visibility']
          unless work_attributes['embargo_release_date'].blank?
            file_attributes[:embargo_release_date] = work_attributes['embargo_release_date']
            file_attributes[:visibility_during_embargo] = work_attributes['visibility_during_embargo']
            file_attributes[:visibility_after_embargo] = work_attributes['visibility_after_embargo']
          end

          file_attributes
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
