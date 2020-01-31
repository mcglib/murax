require 'pathname'
class WriteEmbeddedMetadataToFile

   def initialize(filepathname,metadata)
     begin
        raise ArgumentError.new("Missing required file name argument.") if filepathname.nil?
        raise ArgumentError.new("Missing or invalid required metadata argument") if metadata.nil?
        raise ArgumentError.new("Invalid metadata format. Hash required.") if !metadata.instance_of? Hash
        @the_file = Pathname.new("#{filepathname}")
        if !(@the_file.exist? && @the_file.file?)
           raise Errno::ENOENT.new("#{@the_file.to_s} is not a valid file.")
        end
        @md_as_hash = metadata
     rescue ArgumentError, Errno::ENOENT, StandardError => e
        puts e.message
        @the_file = nil
        @md_as_hash = nil
     end
   end

   def replace_metadata
      message = ''
      begin
         # delete existing metadata
         cmd = "exiftool -all= '#{@the_file.realpath}'"
         result = system(cmd)
         raise StandardError.new "Unable to remove existing file metadata." if !(result == true)
         # add new metadata
         # md_as_hash must use exiftool metadata tags, not field names, as hash keys
         # see output of FetchEmbeddedMetadataFromFile service as an example.
         @md_as_hash.each do |k,v|
            new_value = v.strip
            #cmd = "exiftool -#{k}='#{new_value}' '#{@the_file.realpath}'"
            #message += `#{cmd}`
            message += %x[exiftool -#{k}="#{new_value}" "#{@the_file.realpath}"]
         end
      rescue StandardError => e
         puts e.message
         @md_as_hash = nil
      end
      message
   end

   def update_fields
      message = ''
      begin
         @md_as_hash.each do |k,v|
           new_value = v.strip
           #cmd="exiftool -#{k}='#{new_value}' '#{@the_file.realpath}'"
           #message += `#{cmd}`
           message += %x[exiftool -#{k}="#{new_value}" "#{@the_file.realpath}"]
         end
      rescue StandardError => e
        puts e.message
        @md_as_hash = nil
      end
      message
   end
end
