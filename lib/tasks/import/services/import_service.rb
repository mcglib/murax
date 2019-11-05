module Import
  module Services
    
    attr_accessor :resource, :item
    class ImportService
     def initialize(user,item,work_attributes,work_type)
        @work_attributes = work_attributes
        @user = user
        @item = item
        @work_type = work_type
     end

      def create_a_work_record
         @resource = @work_type.constantize.new
         @resource.depositor = @user.id
         @resource.save

        # Singularize non-enumerable attributes
        @work_attributes.each do |k,v|
         if @resource.attributes.keys.member?(k.to_s) && !@resource.attributes[k.to_s].respond_to?(:each) && @work_attributes[k].respond_to?(:each)
            @work_attributes[k] = v.first
         else
            @work_attributes[k] = v
         end
        end
   
        # Only keep attributes which apply to the given work type
        @work_attributes.select {|k,v| k.ends_with? '_attributes'}.each do |k,v|
          if !@resource.respond_to?(k.to_s+'=')
            @work_attributes.delete(k.split('s_')[0]+'_display')
            @work_attributes.delete(k)
          end
        end
        @resource.attributes = @work_attributes.reject{|k,v| !@resource.attributes.keys.member?(k.to_s) unless k.ends_with? '_attributes'}

        @resource.visibility = @work_attributes['visibility']
        @resource.admin_set_id = @work_attributes['admin_set_id']
        @resource
      end

      def create_a_file_record
         file_set = FileSet.new
         file_attributes = Hash.new
         # Singularize non-enumerable attributes
          @work_attributes.each do |k,v|
            if file_set.attributes.keys.member?(k.to_s)
              if !file_set.attributes[k.to_s].respond_to?(:each) && @work_attributes[k].respond_to?(:each)
                file_attributes[k] = v.first
              else
                file_attributes[k] = v
              end
            end
          end
          file_attributes[:date_created] = @work_attributes['date_created']

          file_attributes
      end

      def add_a_thesis_file_set(file_attributes,file_name,base_file_path)
          if !file_name.nil?
            file_set = nil
            case file_name
               when /CERTIFICATE/
                 file_attributes['visibility'] = 'restricted'
                 new_title = @resource.attributes['title'].first+" - license"
                 file_attributes['title'][0] = new_title
               when /MULTIMEDIA/
                 file_attributes['visibility'] = 'open'
                 new_title = @resource.attributes['title'][0] + " - supplement"
                 file_attributes['title'][0] = new_title
               else
                 file_attributes['visibility'] = 'open'
            end
            file_part_of_name = file_name.split('/').last
            file_attributes['label']=file_part_of_name
            retry_op('creating fileset') do
              file_set = FileSet.create(file_attributes)
            end
            actor = Hyrax::Actors::FileSetActor.new(file_set,@user)
            actor.create_metadata(file_attributes)
            #fetch the file
            uploaded_file = "#{base_file_path}/#{@resource.id}/#{file_part_of_name}"
            bitstream = open(file_name)
            IO.copy_stream(bitstream,uploaded_file)
            retry_op('reading file') do
              actor.create_content(Hyrax::UploadedFile.create(file: File.open(uploaded_file), user: @user))
            end
            retry_op('attaching file to thesis') do
              actor.attach_to_work(@resource,file_attributes)
            end
          end
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
  end
end
