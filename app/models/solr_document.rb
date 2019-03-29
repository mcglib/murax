# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
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

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

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

  def orcidid
    self[Solrizer.solr_name('orcidid')]
  end
end 
