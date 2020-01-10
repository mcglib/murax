require 'pathname'
class WriteEmbeddedMetadataToFile

   def initialize(filepathname,metadata)
     begin
        raise ArgumentError.new("Missing required file name argument.") if filepathname.nil?
        raise ArgumentError.new("Missing or invalid required metadata argument") if metadata.nil?
        raise ArgumentError.new("Invalid metadata format. Hash required.") if !metadata.instance_of? Hash
        @the_file = Pathname.new("tmp/#{filepathname}")
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
      begin
         # delete existing metadata
         cmd = "exiftool -all= '#{@the_file.realpath}'"
         puts "cmd: #{cmd}"
         result = `#{cmd}`
         puts "result: " + result.to_s
         # add new metadata
         # md_as_hash must use exiftool metadata tags, not field names, as hash keys
         # see output of FetchEmbeddedMetadataFromFile service as an example.
         @md_as_hash.each do |k,v|
            new_value = v.strip
            cmd = "exiftool -#{k}='#{new_value}' '#{@the_file.realpath}'"
            puts "cmd: #{cmd}"
            result = `#{cmd}`
            puts "result: " + result.to_s
         end
      rescue StandardError => e
         puts e.message
      end
   end

   def update_fields
      begin
         @md_as_hash.each do |k,v|
           new_value = v.strip
           cmd="exiftool -#{k}='#{new_value}' '#{@the_file.realpath}'"
           puts "cmd: #{cmd}"
           result = `#{cmd}`
           puts "result: " + result.to_s
           #raise RunTimeError.new("Unable to update #{k} field with new value: #{v}") if !result.nil?
         end
      rescue StandardError => e
        puts e.message
      end
   end
end
