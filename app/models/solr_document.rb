# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # etdms adds the following fields: institution, department, degree
  use_extension(Blacklight::Document::Etdms)

  # Do content negotiation for AF models. 
  use_extension( Hydra::ContentNegotiation )

 
  field_semantics.merge!(
    description: "description_tesim",
    abstract: "abstract_tesim",
    creator: "creator_tesim",
    contributor: "contributor_tesim",
    date: "date_tesim",
    subject: "subject_tesim",
    title: "title_tesim",
    degree: "degree_tesim",
    language: "language_tesim",
    source: "source_tesim",
    relation: "relation_tesim",
    institution: "institution_tesim",
    department: "department_tesim",
    publisher: "publisher_tesim",
    type: "rtype_tesim",
    rights: 'rights_tesim',
    identifier:  "oai_identifier"
  )

  def [](key)
    return send(key) if %w[ oai_identifier ].include?(key)

    super
  end

  def oai_identifier
    if self['has_model_ssim'].first.to_s == 'Collection'
      Hyrax::Engine.routes.url_helpers.url_for(only_path: false, action: 'show', host: CatalogController.blacklight_config.oai[:provider][:repository_url], controller: 'hyrax/collections', id: id)
    #elsif self['has_model_ssim'].first.to_s == 'Thesis'
    #  Rails.application.routes.url_helpers.url_for(only_path: false, action: 'file_manager', host: CatalogController.blacklight_config.oai[:provider][:repository_url], controller: "hyrax/#{self['has_model_ssim'].first.to_s.underscore.pluralize}", id: id)
    else
      Rails.application.routes.url_helpers.url_for(only_path: false, action: 'show', host: CatalogController.blacklight_config.oai[:provider][:repository_url], controller: "hyrax/#{self['has_model_ssim'].first.to_s.underscore.pluralize}", id: id)
    end
  end

  def sets
    fetch('isPartOf', []).map { |m| BlacklightOaiProvider::Set.new("isPartOf_ssim:#{m}") }
  end

  def to_oai_etdms
    export_as('oai_etdms_xml')
  end

  def nested_ordered_creator_label
    Murax::OrderedParserService.parse(self["nested_ordered_creator_label_tesim"]) || []
  end

  def creator
     nested_ordered_creator_label.present? ? nested_ordered_creator_label : self[Solrizer.solr_name('creator', :stored_searchable)] || []
  end

  def title
    #self[Solrizer.solr_name('title')]
    self["title_tesim"]
  end

  def abstract
    self["abstract_tesim"]
  end

  def institution
    self["institution_tesim"]
  end

  def degree
    self["degree_tesim"]
  end

  def department
    self["department_tesim"]
  end

  def faculty
    self["faculty_tesim"]
  end

  def rights
    self["rights_tesim"]
  end
  
  def rtype
    self["rtype_tesim"]
  end

  def date
    self["date_tesim"]
  end

  def date_accepted
    self["date_accepted_tesim"]
  end

  def orcidid
    self["orcidid_tesim"]
  end
  
  def language
    self["language_tesim"]
  end


  def language_label
    self["language_label_tesim"]
  end

  def relation
    self["relation_tesim"]
  end

  def bibliographic_citation
    self["bibliographic_citation_tesim"]
  end 

  def related_url
    self["related_url_tesim"]
  end

  def alternative_title
    self["alternative_title_tesim"]
  end

  def local_affiliated_centre
    self["local_affiliated_centre_tesim"]
  end

  def pmid
    self["local_affiliated_centre_tesim"]
  end

  def research_unit
    self["research_unit_tesim"]
  end

  def grant_number
    self["grant_number"]
  end

  def status
    self["status_tesim"]
  end
  
  def source
    self["source_tesim"]
  end

  def report_number
    self["report_number_tesim"]
  end 

  def creator
    self["creator_tesim"]
  end 

  def contributor
    self["contributor_tesim"]
  end 

  def work_description
    self["work_description_tesim"]
  end 

  def publisher
    self["publisher_tesim"]
  end 

  def subject
    self["subject_tesim"]
  end 

  def extent
    self["extent_tesim"]
  end 

  def identifier
    self["identifier_tesim"]
  end 

  def note
    self["note_tesim"]
  end 

  def license
    self["license_tesim"]
  end

  def author_order
    self["author_order_tesim"]
  end
end 
