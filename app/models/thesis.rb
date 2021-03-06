# Generated via
#  `rails generate hyrax:work Thesis`
class Thesis < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::HasSolrLabels
  include Hyrax::HasNestedOrderedProperties
  self.indexer = ThesisIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your Thesis/Dissertation must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::DefaultMetadata
end
