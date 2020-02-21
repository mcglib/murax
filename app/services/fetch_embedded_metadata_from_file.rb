require 'pathname'

class FetchEmbeddedMetadataFromFile

   def initialize(filepathname)
      begin
         raise ArgumentError.new("Missing required argument full file path.") if filepathname.nil?
         @the_file = Pathname.new(filepathname)
         if !(@the_file.exist? && @the_file.file?)
            raise Errno::ENOENT.new("#{@the_file.to_s} is not a valid file.")
         end
      rescue ArgumentError, Errno::ENOENT, StandardError => e
        puts e.message
        @the_file = nil
      end
   end

   def fetch_as_hash
      @md_hash = Hash.new()
      return @md_hash if @the_file.nil?
      begin
         cmd = "exiftool -s -u '" + @the_file.to_s + "'"
         md = `#{cmd}`
         if /Unknown file type/.match(md).nil?
           md.each_line do |l|
             k,v = l.split(/:/,2)
             @md_hash[k.strip]=v.strip
           end
         end
         @md_hash
      rescue StandardError => e
         puts e.message
      end
   end
end
