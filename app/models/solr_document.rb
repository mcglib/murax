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
    Murax::OrderedParserService.parse(self[Solrizer.solr_name('nested_ordered_creator_label', :symbol)]) || []
  end

  def creator
     nested_ordered_creator_label.present? ? nested_ordered_creator_label : self[Solrizer.solr_name('creator', :stored_searchable)] || []
  end

  def title
    self[Solrizer.solr_name('title')]
  end

  def abstract
    self[Solrizer.solr_name('abstract')]
  end

  def institution
    self[Solrizer.solr_name('institution')]
  end

  def degree
    self[Solrizer.solr_name('degree')]
  end

  def department
    self[Solrizer.solr_name('department')]
  end

  def faculty
    self[Solrizer.solr_name('faculty')]
  end

  def rights
    self[Solrizer.solr_name('rights')]
  end
  
  def rtype
    self[Solrizer.solr_name('rtype')]
  end

  def date
    self[Solrizer.solr_name('date')]
  end

  def date_accepted
    self[Solrizer.solr_name('date_accepted')]
  end

  def orcidid
    self[Solrizer.solr_name('orcidid')]
  end
  
  def language
    self[Solrizer.solr_name('language')]
  end


  def language_label
    self[Solrizer.solr_name('language_label')]
  end

  def relation
    self[Solrizer.solr_name('relation')]
  end

  def bibliographic_citation
    self[Solrizer.solr_name('bibliographic_citation')]
  end 

  def related_url
    self[Solrizer.solr_name('related_url')]
  end

  def alternative_title
    self[Solrizer.solr_name('alternative_title')]
  end

  def local_affiliated_centre
    self[Solrizer.solr_name('local_affiliated_centre')]
  end

  def pmid
    self[Solrizer.solr_name('pmid')]
  end

  def research_unit
    self[Solrizer.solr_name('research_unit')]
  end

  def grant_number
    self[Solrizer.solr_name('grant_number')]
  end

  def status
    self[Solrizer.solr_name('status')]
  end
  
  def source
    self[Solrizer.solr_name('source')]
  end

  def report_number
    self[Solrizer.solr_name('report_number')]
  end 

  def creator
    self[Solrizer.solr_name('creator')]
  end 

  def contributor
    self[Solrizer.solr_name('contributor')]
  end 

  def work_description
    self[Solrizer.solr_name('work_description')]
  end 

  def publisher
    self[Solrizer.solr_name('publisher')]
  end 

  def subject
    self[Solrizer.solr_name('subject')]
  end 

  def extent
    self[Solrizer.solr_name('extent')]
  end 

  def identifier
    self[Solrizer.solr_name('identifier')]
  end 

  def note
    self[Solrizer.solr_name('note')]
  end 

  def license
    self[Solrizer.solr_name('license')]
  end

  def author_order
    self[Solrizer.solr_name('author_order')]
  end
end 
