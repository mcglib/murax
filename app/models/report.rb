# Generated via
#  `rails generate hyrax:work Report`
class Report < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Murax::HasSolrLabels
  include Murax::HasNestedOrderedProperties
  self.indexer = ReportIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your Report must have a title.' }
  # validates_with Murax::Validators::NestedRelatedItemsValidator
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Murax::DefaultMetadata
end
