namespace :migration do
    require 'fileutils'
    require 'htmlentities'
    require 'csv'
    require 'yaml'
    require 'net/http'
    require 'uri'
    require 'json'
    require 'nokogiri'
    require 'open-uri'

    desc 'Verify that the samvera items have all been properly imported. Remove duplicates if any eg: bundle exec rake migration:verify_import[csvfile]'
    task :verify_imported_pids, [:csv_file, :worktype] => :environment do |t, args|
      if args.count < 2
        puts "Usage: bundle exec rake migration:verify_imported_pids[csv_file,'Thesis']"
        puts "Expecting two arguments. found #{args.count}"
        exit
      end
      if args[:worktype] == nil
        puts "error: Work type '#{args[:worktype]}' was not defined."
        exit
      end

      @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
      @xml_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php"

      # check if its a string or a file
      @pid_list = File.read("#{Rails.root}/#{args[:csv_file]}").strip.split("\n")
      @pids = @pid_list
      work_type = args[:worktype]

      # if its a string
      # #@pids = args[:csv_file].split(' ').map{ |s| s.to_i } # first argument

      # clean up the @pids list by removing all archive and supplemental pids
      clean_pids = []
      @pids[0..100].each do | pid |
        xml = fetch_raw_xml(pid, "xml")
        usage_type = set_usage_type(xml)
        item_status = set_item_status(xml)
        related_pids = fetch_related_pids(pid)
        main_view = is_main_view(usage_type, item_status, related_pids)
        clean_pids << pid if main_view
        #puts "Adding pid #{pid} to csv" if main_view
      end

      start_time = Time.now
      puts "[#{start_time.to_s}] Starting to verify that the pids have been imported:\n\n"
      
      imported_pids = check_concern(clean_pids, work_type)
      
      # test by removing one
      #imported_pids.pop

      # Send the items that are missing from the import
      missing_pids = clean_pids - imported_pids
      puts "No missing pids found. All have been imported" if missing_pids.empty?
      puts "#{missing_pids.count} pid(s) reported as not imported. See list below:" if missing_pids.count >= 1
      missing_pids.each do | missing_pid | puts "#{missing_pid}\n" end


      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      puts "[#{end_time.to_s}] Finished the  verification of #{@pids.count} pids in #{duration} minutes"
      
      log.info "Task finished at #{end_time} and lasted #{duration} minutes."
      #send_error_report(batch, @depositor)

      # Send email of what has been completed
      # Send email of the errors that occured

    end
  
    def set_item_status(raw_xml)
     item_status = raw_xml.xpath("digital_entity/control/status").text
     item_status
    end

    def is_main_view(usage_type, item_status, related_pids)
      main_view =  false
      is_suppressed = item_status.eql? 'SUPPRESSED'
      if usage_type.eql? "ARCHIVE" and !is_suppressed and (related_pids.has_value?('VIEW_MAIN') or related_pids.has_value?('VIEW'))
        main_view = false
      end

      if is_suppressed and usage_type.eql? "ARCHIVE"
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
      usage_type_v = raw_xml.at_css('digital_entity control usage_type') if raw_xml.present?
      usage_type_v.text if usage_type_v.present?
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

    def check_concern(csv_pids, work_type)
      imported_pids = []
      wktype = work_type.capitalize.constantize
      total_items = csv_pids.count
      csv_pids.each_with_index do | pid, index |
        #puts "#{Time.now.strftime('%Y%-m%-d%-H%M%S') }:  #{index}/#{total_items}  : Checking the pid  #{pid}."
        my_pid = pid.strip.to_i
        item = wktype.where(relation_tesim: "Pid: #{my_pid}").first
        #csv_pids[index] = "#{my_pid}:imported" if item.present?
        imported_pids << pid if item.present?
      end
      #work_type.capitalize.constantize.find_each do | item |
      #  my_pid = get_digitool_pid(item)
      #  if my_pid.present?
      #    puts "Checking if pid #{my_pid} for workid #{item.id} was ingested" 
      #    #Check if the pid is inside  csv_pids
      #    found = csv_pids.include? my_pid.strip
      #    my_index = csv_pids.index(my_pid.strip)
      #    csv_pids[my_index] = "#{my_pid.strip}:imported" if my_index.present?
      #  end
        #puts "Pid #{my_pid} not found" if !found 
      #end
      imported_pids
    end

    def get_digitool_pid(cur_concern) 
        digitool_pid = nil
        my_pid = cur_concern.relation.select{|item| item.include? "Pid"}.first
        digitool_pid = my_pid.strip.split(":", 2).second if my_pid.present?
        digitool_pid
    end
  end
