require 'active_record'
require 'optparse'
require 'uri'
require 'htmlentities'

namespace :murax do
  desc 'Get the digitool raw xml from import log'
  task :get_digitool_xml_by_workid, [:worktype] => :environment do |task, args|
      worktype = args[:worktype]
      #wkids = args.extra # the rest of the arguments
      wkids = args.extras
      # check if we go other pids
     if wkids.empty? or !worktype.present?
        puts "Usage: bundle exec rake murax:get_digitool_xml_by_workid['worktype, work_id'[,'work-id'...]]"
        puts "       Prints out the digitool xml for a given workid that was imported"
        puts "Expecting atleast two arguments; found #{args.count}."
        exit
     end

     wkids.each do |work_id|
       #fetch object
       xml = Murax::DigitoolXmlService.get_xml_workid(work_id)
       puts xml if xml.present?
     end

     exit
   end
end
