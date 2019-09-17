require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
class DigitoolItem
  include ActiveModel::Model
  # this will create for you the reader and writer for this attribute
  attr_accessor :raw_xml, :added, :pid, :collection_id,
                :related_pids, :metadata_hash, :title,
                :file_info, :file_path, :file_name,
                :work_type, :metadata_xml, :local_collection_code, :item_type, :item_status

  # validates
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

    # get the raw metadata_xml
    # set usage type
    set_usage_type

    # set item status
    set_item_status

    set_metadata if !is_waiver? or is_suppressed?

    set_related_pids

    @file_info = set_file_metadata

  end

  def set_title
    #set the title from the clean xml
    @title = @metadata_hash['title']
  end

  def parse(config, depositor)
      admin_set = config['admin_set']
      env_default_admin_set = 'Default Admin Set'

      work_attributes = get_work_attributes(config, depositor)
      child_works = Array.new

      work_attributes['admin_set_id'] = AdminSet.where(title: admin_set).first || AdminSet.where(title: env_default_admin_set).first.id

      { work_attributes: work_attributes.reject!{|k,v| v.blank?},
        child_works: child_works }
  end

  def set_metadatahash(xml)
    metadata_hash = nil
    # Here we remove the weird prefixes not recognized
    normalized_xml = xml.gsub(/dcterms/, 'ns1')

    metadata_hash = Hash.from_xml(normalized_xml)

    metadata_hash

  end

  def get_metadata

      doc = nil
      @raw_xml.xpath("/digital_entity/mds/md").each do | md_xml |
        if md_xml.at_css("name").text == 'descriptive'
          val = Nokogiri::XML(md_xml.at_css("value")) if md_xml.present?
          doc = val.to_s if val.present?
        end
      end

      doc

  end

  # Returns an array of abstract strings with
  # attached prefixes and defaults to 'en'
  # where abstract is only one
  # eg
  # FR:Voici ma thèse…
  # EN:Here’s my thesis…
  def set_abstracts(abstract_xmls)
    abstracts = []
    abstract_xmls.each do | abstract |
      lang = abstract.attributes['lang'].present? ? abstract.attributes['lang'].text : 'en'
      abstracts << add_language_prefix_to_text(lang, abstract.text) if abstract.text.present?
    end

    abstracts
  end

  def add_language_prefix_to_text(lang,text)
    prefixed_text = text
    if lang.present? and text.present?
      prefixed_text = "\"#{text}\"@#{lang}"
    end
    prefixed_text
  end

  def is_suppressed?
    @item_status.eql? 'SUPPRESSED'
  end

  def set_item_status
    @item_status = @raw_xml.xpath("digital_entity/control/status").text
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

  def set_related_pids
    @related_pids = fetch_related_pids(@pid) if @pid.present?
  end

  def get_url_identifier(work_id)
      url = nil

      if work_id.present?
       url = "https://#{ENV["SITE_URL"]}/concern/#{@work_type.pluralize.downcase}/#{work_id}"
      end
      url
  end

  def get_related_pids
    fetch_related_pids(@pid) if @pid.present?
  end

  def has_related_pids?
    @related_pids.present?
  end

  def set_metadata
      # get the descriptive metadata
      @raw_xml.xpath("/digital_entity/mds/md").each do | md_xml |
        if md_xml.at_css("name").text == 'descriptive'
          doc = Nokogiri::XML(md_xml.at_css("value")) if md_xml.present?
          data = Hash.from_xml(doc.to_s)
          @metadata_hash = data['record']
        end
      end
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

  def get_technical_xml
      @raw_xml.at_css('digital_entity control') if @raw_xml.present?
  end

  def set_file_metadata
      if @raw_xml.present? && !@file_info.present?
        @file_info = {}

        @file_info['file_name'] = get_raw_file_name
        @file_info['file_ext'] = @raw_xml.at_css('digital_entity stream_ref file_extension').text
        @file_info['mime_type'] = @raw_xml.at_css('digital_entity stream_ref mime_type').text
        @file_info['path'] = @raw_xml.at_css('digital_entity stream_ref directory_path').text
        @file_info['representative_media'] = false
      end
      @file_info
  end


  def download_file(dest=nil)
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

  def get_proper_date(value)

    date_val = ""
    if value.present?
      date_val = (value.upcase == 'YYYY') ? 'XXXX' : value
    end

    date_val

  end

  def get_file_name
    @file_info = set_file_metadata unless @file_info.present?
    @file_info['file_name']
  end

  # Use language code to get iso639-2 uri from service
  def get_language_uri(language_codes)
    language_codes.map{|e| LanguagesService.label("http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}") ?
            "http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}" : e}
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

  def ordered_properties
    %w[title creator abstract contributor additional_information]
  end

  def process_ordered_field(property,value, index)
    # Grab the property name
    return { index: index.to_s, property.to_s.to_sym => value }
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

  def set_filename_and_type(fname, usage_type)
      my_hash = fname
      #puts "#{@pid} -- #{fname} -- #{usage_type}"
      my_hash
  end

    def get_localfilename_field
      file_names = []
      doc = Nokogiri::XML(get_metadata)
      doc.remove_namespaces!

      # get the first file. its always the main file

      # find all filenames in desc metadata
      doc.xpath("/record/localfilename").each_with_index do |furl, index|
        fname = furl.text
        if fname.include? 'http://'
          uri = URI.parse(fname.gsub(/\n/, ""))
          file_names << set_filename_and_type(File.basename(uri.path),@usage_type)
        else
          file_names << set_filename_and_type(fname,@usage_type)
        end
      end

      file_names
    end

    def get_raw_file_name
      file_name = @raw_xml.at_css('digital_entity stream_ref file_name').text

      if file_name.include? 'downloaded_stream'
        # get other names
        localfilenames = get_localfilename_field
        if localfilenames.count == 1 and (@usage_type == 'VIEW_MAIN' or @usage_type == 'VIEW')
            file_name = localfilenames.first
        end

        if localfilenames.count > 1
          if @usage_type == 'VIEW_MAIN'
            file_name = localfilenames.first
          end

          # lets circle through the filenames to get our info
          localfilenames.each_with_index do |fname, idx|
            if fname.downcase.include? 'multimedia' and @usage_type == 'VIEW'
              file_name = fname
            end
            if fname.downcase.include? 'certificate' and @usage_type == 'ARCHIVE'
              file_name = fname
            end
          end
        end

      end

      file_name
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
