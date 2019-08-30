# Generated via
#  `rails generate hyrax:work Paper`
require 'app/helpers/ordered_string_helper'
include OrderedStringHelper

class Paper < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = PaperIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your paper must have a title.' }

  self.human_readable_type = 'Paper'
#
  # we want to handle the language list as an ordered set
  #
  def language
    return OrderedStringHelper.deserialize(super )
  end

  def language= values
    super OrderedStringHelper.serialize(values )
  end

  #
  # we want to handle the keyword list as an ordered set
  #
  def keyword
    return OrderedStringHelper.deserialize(super )
  end

  def keyword= values
    super OrderedStringHelper.serialize(values )
  end





  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata


end
