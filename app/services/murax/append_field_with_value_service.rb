# frozen_string_literal: true
require 'active_record'
require 'csv'

module Murax
    class AppendFieldWithValueService
        @logger = nil
        @nested_ordered_elements = []
        attr_reader :work_object, :pid, :csv_value, :fieldname

        def initialize(fieldname, value, pid, work_object)
            @nested_ordered_elements =  { 'nested_ordered_creator' => 'nested_ordered_creator' }
            @logger = Logger.new(File.join(Rails.root, 'log', 'append-fields-values.log'))
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

        def append
            status = true
            #puts "Overwrite #{@fieldname} for work id #{@work_id} with #{@csv_value}"
            # Here we pass to the object service to update a single fieldname
            if csv_value.include? '|'
                @logger.info "Cannot append multi-valued field (CSV contains: #{csv_value} for work id #{work_id})"
                status = false
            end

            begin
                #if @work_object[@fieldname].is_a?(ActiveTriples::Relation)
                unless @csv_value.nil? 
                    if @nested_ordered_elements.key?(@fieldname)
                        status = append_nested_field 
                    elsif @work_object[@fieldname].instance_of? String
                        status = append_basic_field
                    else
                        status = append_multivalued_field
                    end

                    raise StandardError if !status
                end
                # Return the updated object
            rescue StandardError => e
                puts "error was #{e.message}"
                @logger.error "Error was #{e.message}"
            end

            status
        end
        def append_nested_field
            nested_fieldname = @nested_ordered_elements[@fieldname]
            status = true
            indexed_values = []

            work_value = @work_object.attributes[@fieldname]
            first_value = work_value.entries.first.creator
            begin
                case @fieldname
                when 'nested_ordered_creator'
                    @work_object.nested_ordered_creator = nil
                    @csv_value.split('|').each_with_index do |obj_value, obj_i|
                        new_field = { index: obj_i.to_s, creator: "#{first_value.first}, #{obj_value}" }
                        new_nested_item = @work_object.nested_ordered_creator.build(new_field)
                        @work_object.nested_ordered_creator <<  new_nested_item
                    end
                else
                    @logger.error("#{@work_object.class} #{@work_id} #{field_name} unable to handle this type of ordered_*, rake task requires work to process these updates.")
                end
                @work_object.save!
            rescue StandardError => e
                puts "Error appending a nested ordered #{@fieldname} on the workid #{@work_id}. Error was #{e.message}"
                @logger.error "Error appending a nested ordered #{@fieldname} on the workid #{@work_id}. Error was #{e.message}"
                status = false
            end

            status
        end

        def append_basic_field
            status = true
            begin
                work_value = @work_object.attributes[@fieldname]
                SearchAndReplaceInFieldOfObject.new(work_value, "#{work_value} #{@csv_value}", @fieldname, @work_object)
            rescue StandardError => e
                puts "Error appending a single string on the field #{@fieldname}. Error was #{e.message}"
                @logger.error "Error appending a single string on the field #{@fieldname}. Error was #{e.message}"
                status = false
            
            end

            status
        end
        
        def append_multivalued_field
            status = false
            #puts "update a multivalued field #{@fieldname}"
            work_value = @work_object.attributes[@fieldname]
            values = setup_values(@csv_value)
            begin
                @logger.error "work #{@pid} has more than one #{@fieldname} field. Cannot append."
                unless work_value.count > 1
                    first_value = work_value.entries.first
                    SearchAndReplaceInFieldOfObject.new(first_value, "#{first_value}, #{values.join(',')}", @fieldname, @work_object)
                    status = true
                end
                raise StandardError "work #{@pid} has more than one #{@fieldname} field. Cannot append." if work_value.count > 1

            rescue StandardError => e
                puts "Error appending a multivalued field #{@fieldname} on workid #{@work_id}. Error  was #{e.message}"
               @logger.error "Error appending a multivalued field #{@fieldname} on workid #{@work_id}. Error  was #{e.message}"
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