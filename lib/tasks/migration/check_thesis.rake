namespace :migration do
    require 'fileutils'
    require 'htmlentities'
    require 'csv'
    require 'yaml'
    # Maybe switch to auto-loading lib/tasks/migrate in environment.rb
    require 'tasks/migration/migration_logging'
    require 'tasks/migration/migration_constants'
    require "tasks/migration/services/migrate_service"
    require 'tasks/migration/services/metadata_parser'
    require 'tasks/migration/services/import_service'
    require 'tasks/migration_helper'

    # bundle exec rake migraton:digitool_item -- -p 12007 -c 'thesis'
    desc 'Verify that the thesis items have all been properly imported. Remove duplicates if any eg: bundle exec rake migration:check_thesis[csvfile]'
    task :check_thesis, [:csv_file] => :environment do |t, args|

      @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
      @xml_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php"
      @pid_list = File.read("#{Rails.root}/#{args[:csv_file]}").strip.split("\n")
      @pids = @pid_list
      # clean up the @pids list by removing all archive and supplemental pids

      clean_pids = []
      @pids[0,5].each do | pid |
        xml = fetch_raw_xml(pid)
        usage_type = set_usage_type(xml)
        item_status = set_item_status(xml)
        related_pids = fetch_related_pids(pid)
        main_view = is_main_view(usage_type, item_status, related_pids)
        byebug
        clean_pids << pid if main_view
      end
      check_thesis(clean_pids)
      #send_error_report(batch, @depositor)


    end
  
    def set_item_status(raw_xml)
     item_status = raw_xml.xpath("digital_entity/control/status").text
     item_status
    end

    def is_main_view(usage_type, item_status, related_pids)
      main_view =  false
      is_suppressed = item_status.eql? 'SUPPRESSED'
      if usage_type.eql? "ARCHIVE" and !is_suppressed? and (related_pids.has_value?('VIEW_MAIN') or related_pids.has_value?('VIEW'))
        main_view = false
      end

      if is_suppressed? and usage_type.eql? "ARCHIVE"
        main_view = true
      end

      # if the usage is VIEW_MAIN
      if usage_type.eql? "VIEW_MAIN"
        main_view =  true
      end

      if usage_type.eql? "VIEW"
        main_view = related_pids.has_value?('VIEW_MAIN') ? false : true
      end


      main_view
    end
    def fetch_related_pids(pid)
        related_pids = nil
        if pid.present?
          uri = URI.parse("#{@scripts_url}?pid=#{pid}")
          res = Net::HTTP.get_response(uri)
          my_pids = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
          related_pids = my_pids["#{pid}"].except("usage_type")
        end

        related_pids

    end

  
    def set_usage_type(raw_xml)
      usage_type = raw_xml.at_css('digital_entity control usage_type').text if raw_xml.present?
      usage_type
    end
    
    def fetch_raw_xml(pid, format="json")
      xml = nil
      if pid.present?
        uri = URI.parse("#{@xml_url}?pid=#{pid}&return=#{format}")
        res = Net::HTTP.get_response(uri)
        if (format == 'json')
         xml = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
        else
         xml =  Nokogiri::XML.parse(res.body) if res.is_a?(Net::HTTPSuccess)
        end
      end
      xml

    end

    # Not completed yet!
    def send_error_report(batch, user)
      # Find all items that are part of a given batch
      ImportMailer.import_email(user,batch).deliver
    end

    def check_thesis(csv_pids)
      Thesis.find_each do | item |
        my_pid = get_thesis_pid(item)
        #Check if the pid is inside ny csv_pids
        found = csv_pids.include? my_pid.strip
        my_index = csv_pids.index(my_pid.strip)
        csv_pids[my_index] = "#{my_pid.strip}:found" if my_index.present?
        #puts "Found" if found
        #puts "Pid #{my_pid} not found" if !found 
      end
      csv_pids.each do |item| puts item end

      # Send email of what has been completed
      # Send email of the errors that occured
    end

    def get_thesis_pid(thesis) 
        thesis_pid = nil
        my_pid = thesis.relation.select{|item| item.include? "Pid"}.first
        thesis_pid = my_pid.strip.split(":", 2).second
        thesis_pid
    end
  end
