# frozen_string_literal: true
require 'active_record'
require 'csv'

module Murax
    class UpdateFieldWithValueService 
        @logger = nil
        @nested_ordered_elements = []
        attr_reader :work_object, :pid, :csv_value, :fieldname

        def initialize(fieldname, value, pid, work_object)
            @nested_ordered_elements =  { 'nested_ordered_creator' => 'nested_ordered_creator_attributes' }
            begin
                raise ArgumentError.new("Missing required argument work_object.") if work_object.nil?
                raise ArgumentError.new("Updates to the #{@field_name} field are not yet supported") if @field_name == 'creator'
                @work_object = work_object
                @work_id = pid
                @csv_value = value
                @fieldname = fieldname.to_s
            rescue ArgumentError, Errno::ENOENT, StandardError => e
                puts e.message
            end
        end

        def update
            status = false
            puts "Overwrite #{@fieldname} for work id #{@work_id} with #{@csv_value}"
            # Here we pass to the object service to update a single fieldname
            begin
                if @nested_ordered_elements.key?(@fieldname)
                    status = update_nested_field 
                elsif @work_object[@fieldname].instance_of? String
                    status = update_basic_field
                else
                    status = updated_multivalued_field
                end

                raise StandardError if !status

                # Return the updated object
            rescue StandardError => e
                puts "error was #{e.message}"
                ##@logger.error "Error was #{e.message}"

            end

            status
        end

        def update_nested_field
            nested_fieldname = @nested_ordered_elements[@fieldname]
            byebug
            status = true
            puts "update a nested ordered element #{@fieldname} with value:  #{@csv_value}"
            @work_object[@fieldname].clear
            new_field = { index: '0', nested_fieldname.to_sym => @csv_value }
            
            begin
                work_field = work_object[@fieldname]
                work_field.build(new_field)
                @work_object.save!
            rescue StandardError => e
                puts "error was #{e.message}"
                #@logger.error "Error was #{e.message}"
                status = false
            end

            status
        end

        def update_basic_field
            status = true
            puts "update a string for the field #{fieldname}"
            begin
                @work_object[fieldname] = csv_value
                @work_object.save!
            rescue StandardError => e
                puts "error was #{e.message}"
                #@logger.error "Error was #{e.message}"
                status = false
            
            end

            status
        end
        
        def updated_multivalued_field
            status = true
            puts "update a multivalued field #{@fieldname}"
            values = setup_values(@csv_value)
            begin
                @work_object[@fieldname] = values
                @work_object.save!
            rescue StandardError => e
                puts "error was #{e.message}"
                ##@logger.error "Error was #{e.message}"
                status = false
            end

            status
        end

        private

        def setup_values(csv_string)
            values = []
            if csv_string.include? '|'
              csv_values = csv_string.split '|' 
              csv_values.each_with_index do |v, i|
                values << v
              end
            else
                values << csv_string
            end

            values
        end
        def update_multiple(fieldname, value, pid, work_object)
            status = true
            byebug
        end
    end
    
end