class IndexAWork

   def initialize
      @error_message = nil
      @status = nil
      @work = nil
   end

   def by_work_id(id)
     @status = nil
     begin
        raise ArgumentError.new("Missing required work id.") if id.nil?
        @work = ActiveFedora::Base.find(id)
        raise StandardError.new("Can't find a work with id #{id}") if @work.nil?
        response = @work.update_index
        @status = (response["responseHeader"]["status"] == 0)
     rescue ArgumentError, StandardError => e
        @error_message = e.message
        @status = false
     end
   end

   def get_status
      @status
   end

   def get_error_message
      @error_message
   end
end
