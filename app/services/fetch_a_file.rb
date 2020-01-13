class FetchAFile
   @file_to_fetch = nil
   @error_message
   def initialize(file_id_or_uri)
      @file_to_fetch = file_id_or_uri
      begin
         raise ArgumentError.new("Missing required file id or URI.") if @file_to_fetch.nil?
      rescue ArgumentError => e
         puts e.message
         false
      end
   end

   def by_uri
     return false if @file_to_fetch.nil?
     byebug
     begin
        puts "by_uri: #{@file_to_fetch}"
        fetched_file = 'tmp/'+@file_to_fetch.split('/')[-1]
        bitstream = open(@file_to_fetch)
        IO.copy_stream(bitstream,fetched_file)
     rescue Timeout::Error => e
        @error_message = "time out error: " + e.message 
     rescue StandardError => e
        @error_message = e.message
        return false
     end
   end

   def by_file_id
     return false if @file_to_fetch.nil?
     begin
         host = ENV['SITE_URL']
         file_set = FileSet.find(@file_to_fetch)
         ext = file_set.label.split('.')[-1]
         uri = "https://#{host}/downloads/#{@file_to_fetch}.#{ext}"
         @file_to_fetch = uri
         self.by_uri
     rescue StandardError => e
         @error_message = e.message
         return false
     end
   end

   def fetch_error?
      return !@error_message.nil?
   end

   def get_error_message
      return @error_message
   end
end
