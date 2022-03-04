
class SearchAndReplaceInFieldOfObject
  @search_val = nil
  @replace_val = nil
  @field = nil
  @object = nil

  def initialize(search,replace,field,object)
       raise ArgumentError.new("Missing required search argument.") if search.nil?
       raise ArgumentError.new("Missing required replace argument.") if replace.nil?
       raise ArgumentError.new("Missing required field argument.") if field.nil?
       raise ArgumentError.new("Missing required object argument") if object.nil?
       @search_val = search
       @replace_val = replace
       @field_name = field
       @samvera_object = object
       raise ArgumentError.new("Updates to the #{@field_name} field are not yet supported") if @field_name.include? 'creator'
       search_and_replace_in_field_of_object
     rescue ArgumentError => e
       puts e.message
     end
   end

  def search_and_replace_in_field_of_object
     if @samvera_object.attribute_names.include? @field_name
        if @samvera_object[@field_name].respond_to?(:each)
           new_field = Array.new
           @samvera_object[@field_name].each do |f|
              new_field << f.gsub(@search_val,@replace_val)
           end
        else
           new_field = @samvera_object[@field_name].gsub(@search_val,@replace_val)
        end
        @samvera_object[@field_name]=new_field
        @samvera_object.save
     else
        puts "Samvera object with id #{@samvera_object.id} does not have a field called #{@field_name}"
        return false
     end
     @samvera_object
  end
end
