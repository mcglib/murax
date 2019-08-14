# Generated via
#  `rails generate hyrax:work GenericWork`
class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your generic work must have a title.' }

  #self.human_readable_type = 'Generic Work'

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
