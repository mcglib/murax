# frozen_string_literal: true
module Murax
  # DigitoolXml Service
  class DigitoolXmlService
    def self.get_xml_by_workid(workid)
      # check that the workid exists
       xml = nil
       begin
          # Lets load the import log for this workid
         import_log = ImportLog.where(work_id: workid).first
         xml = import_log.raw_xml
       rescue ActiveRecord::RecordNotFound
         puts "Couldn't find the xml for the #{workid}. Missing the log record"
       rescue ActiveRecord::ActiveRecordError
         puts "Error occured fetching the xml"
       end

       xml

    end

    private
  end
end
