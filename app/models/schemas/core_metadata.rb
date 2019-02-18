# frozen_string_literal: true
module Schemas
  class CoreMetadata < ActiveTriples::Schema
    property :date,        predicate: RDF::Vocab::DC11.date
    property :date_label,  predicate: RDF::Vocab::DWC.verbatimEventDate
    property :keyword,     predicate: RDF::Vocab::SCHEMA.keywords
    property :rights_note, predicate: RDF::Vocab::DC11.rights
    property :description, predicate: ::RDF::URI.new("http://lib.my.edu/description"), multiple: true do |index|
      index.as :stored_searchable, :facetable
    end
  end
end
