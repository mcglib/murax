# Generated via
#  `rails generate hyrax:work Ethesis`
class Ethesis < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EthesisIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your Ethesis must have a title.' }

  self.human_readable_type = 'ethesis'


  property :description, predicate: ::RDF::URI.new("http://lib.my.edu/description"), multiple: true do |index|
      index.as :stored_searchable, :facetable
  end

  property :department, predicate: ::RDF::URI.new("http://lib.my.edu/departments"), multiple: false do |index|
      index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  apply_schema Schemas::CoreMetadata, Schemas::GeneratedResourceSchemaStrategy.new
  apply_schema Schemas::EthesisMetadata, Schemas::GeneratedResourceSchemaStrategy.new
end
