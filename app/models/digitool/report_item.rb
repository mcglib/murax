class Digitool::ReportItem < DigitoolItem
  def initialize(attributes={})
    super
    #@metadata = clean_metadata
    @metadata_xml = clean_metadata(get_metadata, @local_collection_code)
  end
  # path to the python cleaning module
  def get_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      doc.to_s
  end

  def clean_metadata(raw_metadata)
    doc = Nokogiri::XML(raw_metadata)
    byebug
    xml = nil
      if @pid.present? and @work_type.present?

        #Here we call the python services 
        #depending on the collection we are working on
        case @local_collection_code # a_variable is the variable we want to compare
        when "BREPR"    #compare to 1
          report_class = "CleanMetadata::BioResourceReport";
        when "GRADRES"    #compare to 2
          report_class = "CleanMetadata::TechnicalReport";
        else
          report_class = "CleanMetadata::TechnicalReport";
        end

        service_instance = report_class.constantize
         xml = service_instance.new(@pid, @work_type).clean
      end
    xml
  end
end
