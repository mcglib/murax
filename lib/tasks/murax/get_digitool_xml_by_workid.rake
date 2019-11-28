require 'active_record'
require 'optparse'

namespace :murax do
  desc 'Get the digitool raw xml from import log'
  task :get_digitool_xml_by_workid, [:workid] => :environment do |task, args|
      workid = args[:workid]
      #wkids = args.extra # the rest of the arguments
      wkids = args.extras
      wkids << workid
      # check if we go other pids
     if wkids.empty? or workid.empty?
        puts "Usage: bundle exec rake murax:get_digitool_xml_by_workid[work_id[,'work-id'...]]"
        puts "       Prints out the digitool xml for a given workid that was imported"
        puts "Expecting atleast one arguments; found #{args.count}."
        exit
     end
     export_digitool_xml(wkids)

     exit
  end
  
  desc 'Get the digitool raw xml from import log'
  task :bulk_export_digitool_xml_by_workid, [:csv_file] => :environment do |task, args|
      # check if we go other pids
     csv_file = args[:csv_file]
     if csv_file.empty?
        puts "Usage: bundle exec rake murax:bulk_export_digitool_xml_by_workid[csv_file]"
        puts "       Prints out the digitool xml for a given workid that was imported"
        puts "Expecting atleast one arguments; found #{args.count}."
        exit
     end
     wkids = File.read("#{Rails.root}/#{csv_file}").strip.split(",")
     export_digitool_xml(wkids)
     exit
   end


   def export_digitool_xml(wkids)
     start_time = Time.now
     logger = ActiveSupport::Logger.new("log/export-digitool-xml-#{start_time}.log")
     logger.info "Task started at #{start_time}"
     successes = 0
     errors = 0
     wkids.each do |work_id|
       #fetch object
       xml = Murax::DigitoolService.get_xml_by_workid(work_id)
       pid = Murax::DigitoolService.get_pid_by_workid(work_id)

       puts "<work id='#{work_id}'>#{xml}</work>" if xml.present?

       logger.info "#{work_id} - #{pid}: Found" if xml.present?
       logger.info "#{work_id} - #{pid}: Not found" if !xml.present?

       errors += 1 if !xml.present?
       successes += 1 if xml.present?
     end
      logger.info "Processed #{successes} work(s), #{errors} error(s) encountered"
      end_time = Time.now
      duration = (end_time - start_time) / 1.minute
      logger.info "Task finished at #{end_time} and lasted #{duration} minutes."

   end
end
