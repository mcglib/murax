class Digitool::ReportItem < DigitoolItem
  def initialize(attributes={})
    super
    @metadata = clean_metadata
  end
  # path to the python cleaning module
  def get_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      doc.to_s
  end

  def clean_metadata
    xml = nil
      if @pid.present? and @work_type.present?
        #Here we call the python services
        report_class = "CleanMetadata::BioResourceReport";
        service_instance = report_class.constantize
         xml = service_instance.new(@pid, @work_type).clean
      end
    xml
  end
end
