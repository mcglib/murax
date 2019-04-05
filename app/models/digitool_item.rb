require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
class DigitoolItem 
  include ActiveModel::Model
  # this will create for you the reader and writer for this attribute
  attr_accessor :raw_xml, :added, :pid, :related_pids, :metadata, :title
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :pid, presence: { message: 'Your digitoolitem  must have a pid.' }

  def initialize(attributes={})
    super
    
    @added ||= false
    @scripts_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-related-pids.php"
    @xml_url = "http://internal.library.mcgill.ca/digitool-reports/diverse-queries/hyrax/get-de-with-relations-by-pid.php"

    # get the raw xml
    @raw_xml = fetch_raw_xml(@pid, "xml") if @pid.present?

    # set the raw metadata
    

  end
  
  def set_related_pids
    @related_pids = fetch_related_pids(@pid) if @pid.present?
  end

  def get_raw_metadata
      doc = Nokogiri::XML(@raw_xml.at_css('digital_entity mds md value')) if @raw_xml.present?
      @metadata = Hash.from_xml(doc.to_s)
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

    def fetch_metadata(pid)
    end



end
