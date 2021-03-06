# frozen_string_literal: true
require 'builder'

module Blacklight::Document::Etdms
  def self.extended(document)
    Blacklight::Document::Etdms.register_export_formats(document) if Blacklight::Document::Etdms.is_a_thesis(document) 
  end

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:etdms_xml, "text/xml")
    document.will_export_as(:oai_etdms_xml, "text/xml")
  end

  def etdms_field_names
     [:contributor, :creator, :date, :abstract, :identifier, :language, :publisher, :rights, :subject, :title, :type, :degree, :department, :institution]
  end

  def self.is_a_thesis(document)
    return false if document.nil?
    is_not_a_thesis_object = true
    document._source.select { |field,values| field.to_s.eql? 'type' }.each do |field,values|
       is_not_a_thesis_object = false if values.first.include? 'Thesis'
    end
    !is_not_a_thesis_object
  end

  def export_as_oai_etdms_xml
    is_not_a_thesis_object = true
    self.to_semantic_values.select { |field,values| field.to_s.eql? 'type' }.each do |field,values|
       is_not_a_thesis_object = false if values.first.include? 'Thesis'
    end
    raise OAI::FormatException.new if is_not_a_thesis_object
    xml = Builder::XmlMarkup.new
    xml.tag!("thesis",
             'xmlns' => "http://www.ndltd.org/standards/metadata/etdms/1-0/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => %(http://www.ndltd.org/standards/metadata/etdms/1-0/ http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd)) do
      self.to_semantic_values.select { |field, values| etdms_field_name? field  }.each do |field,values|
        if field.to_s.include? 'identifier'
          # Special for LAC. They want a link which will resolve to the PDF.
          Array.wrap(values).each do |v|
            lac_url = fetch_file_url_from_identifier(v)
            if !lac_url.nil?
              xml.tag! "#{field}", lac_url
            end
            record_url = build_canonical_url(v)
            if !record_url.nil?
              xml.tag! "#{field}", record_url
            end
          end
        end
        if field.to_s.include? 'language'
          Array.wrap(values).each do |v|
            label = v.split('/')[-1]
            if !label.nil?
               xml.tag! "#{field}", label
            end
          end
          next
        end
        if field.to_s.include? 'abstract'
          Array.wrap(values).each do |v|
            xml.tag! "description", v.gsub(/"@\w{2,3}$/,"").delete_prefix("\"")
          end
          next
        end
        next if field.to_s.include? 'degree'
        next if field.to_s.include? 'department'
        next if field.to_s.include? 'institution'
        next if field.to_s.include? 'identifier'
        Array.wrap(values).each do |v|
           xml.tag! "#{field}", v
        end
      end
      xml.tag!("degree") do
        self.to_semantic_values.select { |field, values| etdms_field_name? field}.each do |field,values|
          xml.tag! "name",values.first if field.to_s.include? 'degree'
          xml.tag! "discipline",values.first if field.to_s.include? 'department'
          xml.tag! "grantor",values.first if field.to_s.include? 'institution'
        end
      end
    end
    xml.target!
  end

  alias_method :export_as_etdms_xml, :export_as_oai_etdms_xml

  private

  def etdms_field_name? field
    etdms_field_names.include? field.to_sym
  end

  def build_canonical_url(identifier)
    canonical_url = identifier.gsub(/catalog\/oai\//,'')
    canonical_url
  end

  def fetch_file_url_from_identifier(identifier)
     protocol_str, empty_str, host_str, catalog_str, oai_str, concern_str, model_str, wid_str, fmngr_str = identifier.split('/')
     return if host_str.nil?
     return if !model_str.eql? 'theses'
     file_set = GetRepresentativeFileSetByWorkId.call(wid_str)
     return if file_set.nil?
     file_name_components = file_set.label.split('.')
     file_ext = file_name_components[-1]
     url = protocol_str+'//'+host_str+'/downloads/'+file_set.id+'.'+file_ext
     url
  end
end

