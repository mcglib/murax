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
  
  task :bulk_export_digitool_xml_by_workid, [:csv_file] => :environment do |task, args|
      # check if we go other pids
     csv_file = args[:csv_file]
     if csv_file.empty?
        puts "Usage: bundle exec rake murax:bulk_export_digitool_xml_by_workid[csv_file]"
        puts "       Prints out the digitool xml for a given workid that was imported"
        puts "Expecting atleast one arguments; found #{args.count}."
        exit
     end
     export_digitool_xml(wkids)
     exit
   end

    # Not completed yet!
   def export_digitool_xml(wkids)
     wkids.each do |work_id|
       #fetch object
       xml = Murax::DigitoolXmlService.get_xml_by_workid(work_id)
       puts xml if xml.present?
     end

   end
end
