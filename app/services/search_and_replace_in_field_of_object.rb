class SearchAndReplaceInFieldOfObject
     @search_val = nil
     @replace_val = nil
     @field = nil
     @object = nil

  def initialize(search,replace,field,object)
     @search_val = search
     @replace_val = replace
     @field_name = field
     @samvera_object = object
     abort "missing required search argument" if @search_val.nil?
     abort "missing required replace argument" if @replace_val.nil?
     abort "missing required field argument" if @field_name.nil?
     abort "missing required object argument" if @samvera_object.nil?
     search_and_replace_in_field_of_object
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
     end
     @samvera_object
  end
end
