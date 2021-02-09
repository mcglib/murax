class IndexAnObject

   def initialize
      @error_message = nil
      @status = nil
      @object = nil
   end

   def by_object_id(id)
     @status = nil
     begin
        raise ArgumentError.new("Missing required object id.") if id.nil?
        @object = ActiveFedora::Base.find(id)
        raise StandardError.new("Can't find an object with id #{id}") if @object.nil?
        response = @object.update_index
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
