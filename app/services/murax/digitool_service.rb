# frozen_string_literal: true
module Murax
  # Digitool Service
  class DigitoolService
    def self.get_xml_by_workid(workid)
       xml = nil
       begin
          # Lets load the import log for this workid
         import_log = ImportLog.where(work_id: workid).first
         xml = import_log.raw_xml if import_log.present?
       rescue ActiveRecord::RecordNotFound
         puts "Couldn't find the xml for the #{workid}. Missing the log record"
       rescue ActiveRecord::ActiveRecordError
         puts "Error occured fetching the xml"
       end

       xml
    end
    def self.get_pid_by_workid(workid)
       pid = nil
       begin
          # Lets load the import log for this workid
         import_log = ImportLog.where(work_id: workid).first
         pid = import_log.raw_xml if import_log.present?
       rescue ActiveRecord::RecordNotFound
         puts "Couldn't find the xml for the #{workid}. Missing the log record"
       rescue ActiveRecord::ActiveRecordError
         puts "Error occured fetching the xml"
       end

       pid
    end

    private
  end
end
