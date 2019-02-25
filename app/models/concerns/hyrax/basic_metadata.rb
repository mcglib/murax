# [murax-override] Overriding default basic metadata to follow MAP
require "rdf/vocab"
module Hyrax
  # An optional model mixin to define some simple properties. This must be mixed
  # after all other properties are defined because no other properties will
  # be defined once  accepts_nested_attributes_for is called
  module BasicMetadata
    extend ActiveSupport::Concern

    included do
      property :alternative_title,    predicate: ::RDF::Vocab::DC.alternative, multiple: true do | index |
              index.as :stored_searchable
      end
      property :creator,      predicate: ::RDF::Vocab::DC.creator, multiple: true do | index|
              index.as :stored_searchable,  :facetable
      end
      property :contributor,      predicate: ::RDF::Vocab::DC.contributor, multiple: true do | index |
              index.as :stored_searchable, :facetable
      end
      property :description,   predicate: ::RDF::Vocab::DC11.description, multiple: true 
      
      property :abstract,      predicate: ::RDF::Vocab::DC.abstract, multiple: true do | index |
              index.as :stored_searchable
      end
      
      property :note,      predicate: ::RDF::Vocab::BF2.note, multiple: true
      property :publisher,      predicate: ::RDF::Vocab::DC11.publisher, multiple: false do |index|
              index.as :stored_searchable, :facetable
      end
      property :extent,      predicate: ::RDF::Vocab::DC.extent, multiple: false

      property :date,      predicate: ::RDF::Vocab::DC11.date, multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :subject,      predicate: ::RDF::Vocab::DC11.subject, multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :language,      predicate: ::RDF::Vocab::DC11.language, multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :degree,      predicate: ::RDF::Vocab::BIBO.degree, multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :department,      predicate: RDF::URI.intern('http://purl.org/cerif/frapo/Department'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :faculty,      predicate:   RDF::URI.intern('http://purl.org/cerif/frapo/Faculty'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :rights,      predicate:   ::RDF::Vocab::DC.rights, multiple: true do | index |
              index.as :stored_searchable
      end
      
      property :rtype,      predicate:  ::RDF::Vocab::DC.type, multiple: false do | index |
              index.as :stored_searchable
      end
      
      property :identifier,      predicate:  ::RDF::Vocab::DC.identifier, multiple: false do |index|
              index.as :stored_searchable
      end


      property :relation,      predicate: ::RDF::Vocab::DC11.relation, multiple: true do |index|
              index.as :stored_searchable
      end


      # VIVO
      property :orcid_id,      predicate: RDF::URI.intern('http://vivoweb.org/ontology/core#orcidId'), multiple: true
      property :institution,   predicate: RDF::URI.intern('http://vivoweb.org/ontology/core#University')
      
      property :related_url,      predicate: ::RDF::RDFS.seeAlso, multiple: true 
      
      # Problem vocabs
      property :license,      predicate: ::RDF::Vocab::SCHEMA.license, multiple: true do | index |
              index.as :stored_searchable
      end
      
      property :based_near, predicate: ::RDF::Vocab::FOAF.based_near, class_name: Hyrax::ControlledVocabularies::Location
      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:based_near]
      accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true

    end
  end
end
