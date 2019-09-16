# Generated via
#  `rails generate hyrax:work Paper`
#require 'app/helpers/ordered_string_helper'
#include OrderedStringHelper

class Paper < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::HasSolrLabels
  include Hyrax::HasNestedOrderedProperties

  self.indexer = PaperIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your paper must have a title.' }
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::DefaultMetadata
end
