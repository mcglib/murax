require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
class DigitoolItem
  include ActiveModel::Model
  # this will create for you the reader and writer for this attribute
  attr_accessor :raw_xml, :added, :pid, :related_pids, :metadata_hash, :title, :file_info, :file_path, :file_name, :work_type, :metadata_xml
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :pid, presence: { message: 'Your digitoolitem  must have a pid.' }
  validates :work_type, presence: { message: 'Your digitoolitem  must have a worktype.' }

  def initialize(attributes={})
    super

    @added ||= false
    @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
    @xml_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php"
    @download_url = "http://digitool.library.mcgill.ca/cgi-bin/download-pid-file.pl"

    # get the raw xml
    @raw_xml = fetch_raw_xml(@pid, "xml") if @pid.present?

    # get the clean metadata xml
    @meta_xml = fet
    # set usage type
    set_usage_type


    @file_info = set_file_metadata

    @metadata_hash = set_metadata

    set_title if is_view?

    set_related_pids

  end
 
  def is_main_view?
    !@related_pids.has_value?('VIEW_MAIN') or @usage_type.eql? "VIEW_MAIN"
  end

  def is_view?
    @usage_type.eql? "VIEW" or @usage_type.eql? "VIEW_MAIN"
  end

  def is_waiver?
    @usage_type.eql? "ARCHIVE"
  end

  def set_title
    @title = @metadata_hash['title']
  end

  def set_related_pids
    @related_pids = fetch_related_pids(@pid) if @pid.present?
  end

  def get_related_pids
    fetch_related_pids(@pid) if @pid.present?
  end

  def has_related_pids?
    @related_pids.present?
  end

  def set_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      data = Hash.from_xml(doc.to_s)
      @metadata_hash = data['record']
  end

  def has_metadata?
    !@metadata_hash.nil?
  end

  def set_usage_type
    @usage_type = @raw_xml.at_css('digital_entity control usage_type').text if @raw_xml.present?
    @usage_type
  end

  def get_usage_type
    @usage_type
  end


  def get_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      doc.to_s
  end

  def get_technical_xml
      @raw_xml.at_css('digital_entity control') if @raw_xml.present?
  end

  def set_file_metadata
      if @raw_xml.present? && !@file_info.present?
        @file_info = {}
        @file_info['file_name'] = @raw_xml.at_css('digital_entity stream_ref file_name').text
        @file_info['file_ext'] = @raw_xml.at_css('digital_entity stream_ref file_extension').text
        @file_info['mime_type'] = @raw_xml.at_css('digital_entity stream_ref mime_type').text
        @file_info['path'] = @raw_xml.at_css('digital_entity stream_ref directory_path').text
      end
      @file_info
  end

  def download_main_pdf_file(dest=nil)
      file_path = nil
      if @pid.present? && @file_info['path'].present?

        # set the dest_folder
        file_path = "#{dest}/#{@file_info['file_name']}" if @file_info.present?
        
        url = "#{@download_url}?pid=#{@pid}&dir_path=#{@file_info['path']}"
        download = open(url)
        IO.copy_stream(download, file_path)
      end
      # return the file_path
      file_path

  end

  def get_file_name 
      
    @file_info = set_file_metadata unless @file_info.present?
    @file_info['file_name']

  end

  def get_file_visibility

    visible = nil
    case @usage_type  # was case obj.class
    when 'ARCHIVE'
        visible = 'restricted'
    when 'VIEW', 'VIEW_MAIN'
        visible = 'open'
    else
        visible = 'open'
    end
    # check the file names

    visible
  end


  private 

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

    def fetch_cleanmetadata_xml(pid, worktype, digitool_colcode)
      xml = nil
      if pid.present? and worktype.present? and digitool_colcode.present?
        #Here we call the python bindings
        report_class = digitool_colcode + "Report";
        service_instance = report_class.constanize
         xml = service_instance.new(pid, worktype).clean
      end
      xml
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



end
