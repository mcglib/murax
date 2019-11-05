require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'byebug'

class GpsoItem
  include ActiveModel::Model
  # this will create for you the reader and writer for this attribute
  attr_accessor :thesis_xml, :added, :collection_id, :title,
                :thesis_file, :waiver_file, :multim_file, :file_info, :file_path

  # validates
  validates :thesis_xml, presence: { message: 'GPSO item must have metadata.' }

  def initialize(attributes={})
    super

    @added ||= false

  end

  def parse(thesis_xml, depositor)
      admin_set = "User Collection"
      env_default_admin_set = 'Default Admin Set'

      work_attributes = Hash.new
      work_attributes['visibility'] = 'open'
      work_attributes['depositor'] = depositor.id
      work_attributes['rtype'] = [thesis_xml.xpath('type').text.strip]

      work_attributes['note'] = []
      work_attributes['note'] << 'ETHESIS'
      work_attributes['note'] << thesis_xml.xpath('isPartOf').text.strip
      work_attributes['note'] << 'Date first available online: ' + Time.now.strftime("%Y-%m-%d") 

      work_attributes['title'] = []
      work_attributes['title'] << thesis_xml.xpath('title').text.strip

      @thesis_file = thesis_xml.xpath('localfilename').first.text.strip
      @waiver_file = thesis_xml.xpath('localfilename[contains(./text(),"CERTIFICATE")]').text.strip
      @multim_file = thesis_xml.xpath('localfilename[contains(./text(),"MULTIMEDIA")]').text.strip

      date_uploaded = DateTime.now.strftime('%Y-%m-%d')
      work_attributes['date_uploaded'] = [date_uploaded.to_s]
      work_attributes['date_modified'] = [date_uploaded.to_s]
      
      work_attributes['nested_ordered_creator_attributes'] = []
      thesis_xml.xpath('creator').each_with_index do |term,index|
         work_attributes['nested_ordered_creator_attributes'] << process_ordered_field("creator", term.text.strip, index) unless term.text.nil? 
      end

      work_attributes['contributor'] = []
      thesis_xml.xpath('contributor').each do |term|
        work_attributes['contributor'] << term.text.strip
      end

      work_attributes['abstract'] = []
      thesis_xml.xpath('abstract').each do |abstract|
        lang = abstract.attributes['lang'].present? ? abstract.attributes['lang'].text.strip : 'en'
        work_attributes['abstract'] << "\"#{abstract.text.strip}\"@#{lang}"
      end

      work_attributes['subject'] = []
      thesis_xml.xpath('subject').each do |term|
        work_attributes['subject'] << term.text.strip
      end

      work_attributes['date_accepted'] = []
      work_attributes['date_accepted'] << Date.strptime(thesis_xml.xpath('localdissacceptdate').text.strip,"%m/%d/%Y").strftime("%Y-%m-%d")

      work_attributes['rights'] = []
      work_attributes['rights'] << thesis_xml.xpath('rights').text.strip

      work_attributes['publisher'] = []
      work_attributes['publisher'] << thesis_xml.xpath('publisher').text.strip

      work_attributes['institution'] = []
      work_attributes['institution'] << thesis_xml.xpath('localdissertationinstitution').text.strip

      work_attributes['degree'] = []
      work_attributes['degree'] << thesis_xml.xpath('localthesisdegreename').text.strip

      work_attributes['department'] = []
      work_attributes['department'] << thesis_xml.xpath('localthesisdegreediscipline').text.strip

      work_attributes['date'] = []
      work_attributes['date'] << thesis_xml.xpath('date').text.strip

      work_attributes['extent'] = thesis_xml.xpath('extent').text.strip

      language = []
      language << thesis_xml.xpath('language').text.strip
      work_attributes['language'] = get_language_uri(language)
      work_attributes['language_label'] = work_attributes['language'].map{|l| LanguagesService.label(l) } if !language.blank?

      work_attributes['admin_set_id'] = AdminSet.where(title: admin_set).first || AdminSet.where(title: env_default_admin_set).first.id
      work_attributes
  end

  def ordered_properties
    %w[title creator abstract contributor additional_information]
  end

  def process_ordered_field(property,value, index)
    return { index: index.to_s, property.to_s.to_sym => value }
  end

  def get_url_identifier(work_id)
      url = nil

      if work_id.present?
       url = "https://#{ENV["SITE_URL"]}/concern/theses/#{work_id}"
      end
      url
  end

  def has_metadata?
    !@thesis_xml.nil?
  end

  def download_file(file_name, dest=nil)
      # TODO
  end

  # Use language code to get iso639-2 uri from service
  def get_language_uri(language_codes)
    language_codes.map{|e| LanguagesService.label("http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}") ?
            "http://id.loc.gov/vocabulary/iso639-2/#{e.downcase}" : e}
  end

  def get_thesis_filename
      @thesis_file if @thesis_file.present?
  end
  
  def get_waiver_filename
      @waiver_file if @waiver_file.present?
  end

  def get_multimedia_filename
      @multim_file if @multim_file.present?
  end


end
