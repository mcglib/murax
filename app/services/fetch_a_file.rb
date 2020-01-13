class FetchAFile

   def initialize
      @error_message = nil
      @fetched_file = nil
   end

   def by_uri(uri)
     begin
        raise ArgumentError.new("Missing required URI.") if uri.nil?
        @fetched_file = 'tmp/'+uri.split('/')[-1]
        bitstream = open(uri)
        IO.copy_stream(bitstream,@fetched_file)
     rescue Timeout::Error => e
        @error_message = "time out error: " + e.message
        @fetched_file = nil 
     rescue ArgumentError, StandardError => e
        @error_message = e.message
        @fetched_file = nil
        false
     end
   end

   def by_file_id(file_id)
     begin
        raise ArgumentError.new("Missing required Samvera file id.") if file_id.nil?
        this_host = ENV['SITE_URL']
        file_set = FileSet.find(file_id)
        raise StandardError.new("Samvera file id #{file_id} not found.") if file_set.nil?
        original_filename = file_set.label
        uri = "http://#{this_host}/downloads/#{file_id}"
        puts "fetching with uri : #{uri}"
        bitstream = open(uri)
        @fetched_file = "tmp/#{original_filename}"
        IO.copy_stream(bitstream,@fetched_file)
     rescue ArgumentError, StandardError => e
        @error_message = e.message
        @fetched_file = nil
        false
     end
   end


   def by_file_id_ignore_visibility(file_id)
     begin
         raise ArgumentError.new("Missing required Samvera file id.") if file_id.nil?
         uri = nil
         file_set = FileSet.find(file_id)
         raise StandardError.new("Samvera file id #{file_id} not found.") if file_set.nil?
         original_filename = file_set.label
         rdf_uri = file_set.uri.to_s
         rdf_file = open(rdf_uri)
         rdf_data = rdf_file.read
         rdf_data.match(/ns006\:hasFile *<([^>]*)/) { |m| uri = m.captures[0] if !m.nil? }
         raise StandardError.new("Unable to locate file for id #{file_id}.") if uri.nil?
         bitstream = open(uri)
         @fetched_file = "tmp/#{original_filename}"
         IO.copy_stream(bitstream,@fetched_file)
     rescue ArgumentError, StandardError => e
         @error_message = e.message
         @fetched_file = nil
         false
     end
   end

   def fetch_error?
      !@error_message.nil?
   end

   def fetched_file_name
      @fetched_file
   end

   def get_error_message
      @error_message
   end

end
