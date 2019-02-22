# [murax-override] Overriding default basic metadata to follow MAP
module Hyrax
  # An optional model mixin to define some simple properties. This must be mixed
  # after all other properties are defined because no other properties will
  # be defined once  accepts_nested_attributes_for is called
  module BasicMetadata
    extend ActiveSupport::Concern

    included do
      property :alternative_title,      predicate: RDF::Vocab::DC.alternative('http://purl.org/dc/terms/alternative'), multiple: true do | index |
              index.as :stored_searchable
      end
      property :creator,      predicate: RDF::Vocab::DC.creator('http://purl.org/dc/terms/creator'), multiple: true do | index|
              index.as :stored_searchable,  :facetable
      end

      property :contributor,      predicate: RDF::Vocab::DC.contributor('http://purl.org/dc/terms/contributor'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :description,      predicate: RDF::Vocab::DC11.desciption('http://purl.org/dc/terms/description'), multiple: true 

      property :abstract,      predicate: RDF::Vocab::DC.abstract('http://purl.org/dc/terms/abstract'), multiple: true do | index |
              index.as :stored_searchable
      end

      property :note,      predicate: RDF::Vocab::BF2.note('http://id.loc.gov/ontologies/bibframe/note'), multiple: true


      property :publisher,      predicate: RDF::Vocab::DC11.publisher('http://purl.org/dc/terms/publisher'), multiple: false do |index|
              index.as :stored_searchable, :facetable
      end


      property :extent,      predicate: RDF::Vocab::DC.extent('http://purl.org/dc/terms/extent'), multiple: false

      property :date,      predicate: RDF::Vocab::DC11.date('http://purl.org/dc/elements/1.1/date'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :subject,      predicate: RDF::Vocab::DC11.subject('http://purl.org/dc/elements/1.1/subject'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :language,      predicate: RDF::Vocab::DC11.language('http://purl.org/dc/elements/1.1/subject'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :institution,      predicate: RDF::Vocab::VIVO.University('http://vivoweb.org/ontology/core#University'), multiple: false

      property :degree,      predicate: RDF::Vocab::BIBO.degree('http://purl.org/ontology/bibo/degree'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :department,      predicate: ::RDF::Vocab::FRAPO.Department('http://purl.org/cerif/frapo/Department'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :faculty,      predicate: ::RDF::Vocab::FRAPO.Faculty('http://purl.org/cerif/frapo/Faculty'), multiple: true do | index |
              index.as :stored_searchable, :facetable
      end

      property :rights,      predicate:   ::RDF::Vocab::DC.rights('http://purl.org/dc/terms/rights'), multiple: true do | index |
              index.as :stored_searchable
      end

      property :license,      predicate: ::RDF::Vocab::Schema.license('http://schema.org/license'), multiple: true do | index |
              index.as :stored_searchable
      end

      property :type,      predicate:  ::RDF::Vocab::DC.type('http://purl.org/dc/terms/type'), multiple: false do | index |
              index.as :stored_searchable
      end

      property :orcidid,      predicate: ::RDF::Vocab::VIVO.orcidID('http://vivoweb.org/ontology/core#orcidId'), multiple: true

      property :related_url,      predicate: ::RDF::RDFS.seeAlso('https://www.w3.org/TR/rdf-schema/#ch_seealso'), multiple: true 

      property :identifier,      predicate:  ::RDF::Vocab::DC.identifier('  http://purl.org/dc/terms/identifier'), multiple: false do |index|
              index.as :stored_searchable
      end

      property :relation,      predicate: ::RDF::Vocab::DC11.relation('http://purl.org/dc/elements/1.1/relation'), multiple: true do |index|
              index.as :stored_searchable
      end

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:based_near]
      accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true
    end
  end
end
