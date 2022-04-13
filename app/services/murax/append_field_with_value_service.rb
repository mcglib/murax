# frozen_string_literal: true
require 'active_record'
require 'csv'

module Murax
    class AppendFieldWithValueService 
        def self.append(fieldname,value, pid, work_object)
            byebug
            status = false
            @nested_ordered_elements = { 'nested_ordered_creator' => 'creator' }
            puts "Overwrite #{fieldname} for work id #{work_id} with #{value}"
            # Here we pass to the object service to update a single fieldname
            begin
                if @nested_ordered_elements.key?(fieldname)
                    updated_object = update_nested_field(fieldname, value, work_object)
                elsif work_object[fieldname].instance_of? String
                    updated_object = update_basic_field(fieldname, value, work_object)
                else
                    updated_object = updated_generic_field(fieldname, value, work_object)
                end

                raise StandardError if !updated_object

                # Return the updated object
                updated_object

            rescue StandardError => e
                puts "error was #{e.message}"
                @logger.error "Error was #{e.message}"

            end
        end

        private

        def self.update_nested_field(fieldname, csv_value, work_object)
            nested_fieldname = @nested_ordered_elements[fieldname]
            status = true
            @logger.info "update a nested ordered element #{fieldname} with #{csv_value}"
            work_object[fieldname].clear
            new_field = { index: '0', nested_fieldname.to_sym => csv_value }
            
            begin
                work_field = work_object[fieldname]
                work_field.build(new_field)
                work_object.save!
            rescue StandardError => e
                puts "error was #{e.message}"
                @logger.error "Error was #{e.message}"
                status = false
            end

            [status, work_object]
        end

        def self.update_basic_field(fieldname, csv_value, work_object)
            status = true
            @logger.info "update a string for the field #{fieldname}"
            begin
                work_object[fieldname] = csv_value
                work_object.save!
            rescue StandardError => e
                puts "error was #{e.message}"
                @logger.error "Error was #{e.message}"
                status = false
            
            end

            [status, work_object]
        end
        
        def self.updated_generic_field(fieldname, csv_value, work_object)
            status = true
            @logger.info "update a generic field #{fieldname}"
            begin
                work_object[fieldname] = csv_value
                work_object.save!
            rescue StandardError => e
                puts "error was #{e.message}"
                @logger.error "Error was #{e.message}"
                status = false
            end

            [status, work_object]
        end

        def self.update_multiple(fieldname, value, pid, work_object)
                        status = true
            byebug

        end
    end
    
end