# frozen_string_literal: true
require 'active_record'
require 'csv'

module Murax
    class UpdateFieldWithValueService 
        @logger = nil
        @nested_ordered_elements = []
        attr_reader :work_object, :pid, :csv_value, :fieldname

        def initialize(fieldname, value, pid, work_object)
            @nested_ordered_elements =  { 'nested_ordered_creator' => 'nested_ordered_creator' }
             @logger = Logger.new(File.join(Rails.root, 'log', 'update-fields-updates.log'))
            begin
                raise ArgumentError.new("Missing required argument work_object.") if work_object.nil?
                raise ArgumentError.new("Updates to the #{@field_name} field are not yet supported") if @field_name == 'creator'
                @work_object = work_object
                @work_id = pid
                @csv_value = value
                @fieldname = fieldname.to_s
            rescue ArgumentError, Errno::ENOENT, StandardError => e
                puts e.message
                @logger.error "Cannot append #{work_id}): #{e.message}"
            end
        end

        def update
            status = true
            #puts "Overwrite #{@fieldname} for work id #{@work_id} with #{@csv_value}"
            # Here we pass to the object service to update a single fieldname

            begin
                #if @work_object[@fieldname].is_a?(ActiveTriples::Relation)
                unless @csv_value.nil? 
                    if @nested_ordered_elements.key?(@fieldname)
                        status = update_nested_field 
                    elsif @work_object[@fieldname].instance_of? String
                        status = update_basic_field
                    else
                        status = updated_multivalued_field
                    end

                    raise StandardError "Failed to do an overwrite" if !status
                end
                # Return the updated object
            rescue StandardError => e
                puts "Error doing an overwrite/update on the field #{@fieldname}. Error was #{e.message}"
                @logger.error "Error doing an overwrite/update  on the field #{@fieldname}. Error was #{e.message}"
            end

            status
        end

        def update_nested_field
            nested_fieldname = @nested_ordered_elements[@fieldname]
            status = true
            indexed_values = []

            begin
                case @fieldname
                when 'nested_ordered_creator'
                    @work_object.nested_ordered_creator = nil
                    @csv_value.split('|').each_with_index do |obj_value, obj_i|
                        new_field = { index: obj_i.to_s, creator: obj_value }
                        new_nested_item = @work_object.nested_ordered_creator.build(new_field)
                        @work_object.nested_ordered_creator <<  new_nested_item
                    end
                else
                    @logger.error("#{@work_object.class} #{@work_id} #{field_name} unable to handle this type of ordered_*, rake task requires work to process these updates.")
                end
                @work_object.save!
            rescue StandardError => e
                puts "Error overwriting the nested ordered field #{@fieldname}. Error was #{e.message}"
                @logger.error "error overwriting the nested ordered field #{@fieldname}. Error was #{e.message}"
                status = false
            end

            status
        end

        def update_basic_field
            status = true
            begin
                @work_object[@fieldname] = csv_value
                @work_object.save!
            rescue StandardError => e
                puts "Error occured overwriting a simple basic field #{@fieldname}. Error was #{e.message}"
                @logger.error "Error occured overwriting a simple basic field #{@fieldname}. Error was #{e.message}"
                status = false
            
            end

            status
        end
        
        def updated_multivalued_field
            status = true
            #puts "update a multivalued field #{@fieldname}"
            values = setup_values(@csv_value)
            begin
                @work_object[@fieldname] = values
                @work_object.save!
            rescue StandardError => e
                puts "Error occured updating multivalued field #{@fieldname}.Error was #{e.message}"
                @logger.error "Error occured updating multivalued field #{@fieldname}.Error was #{e.message}"
                status = false
            end

            status
        end

        private

        def setup_values(csv_string)
            values = []
              @csv_value.split('|').each_with_index do |v, i|
                values << v
              end
            values
        end

    end
    
end