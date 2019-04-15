require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
class DigitoolItem 
  include ActiveModel::Model
  # this will create for you the reader and writer for this attribute
  attr_accessor :raw_xml, :added, :pid, :related_pids, :metadata_hash, :title, :file_info, :file_path
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :pid, presence: { message: 'Your digitoolitem  must have a pid.' }

  def initialize(attributes={})
    super
    
    @added ||= false
    @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
    @xml_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php"
    @download_url = "http://digitool.library.mcgill.ca/cgi-bin/download-pid-file.pl"
    
    # get the raw xml
    @raw_xml = fetch_raw_xml(@pid, "xml") if @pid.present?
    
    @file_info = set_file_metadata

    @metadata_hash = set_metadata

  end
  
  def set_related_pids
    @related_pids = fetch_related_pids(@pid) if @pid.present?
  end

  def set_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      data = Hash.from_xml(doc.to_s)
      @metadata_hash = data['record']
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
