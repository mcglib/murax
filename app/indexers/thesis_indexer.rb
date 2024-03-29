# Generated via
#  `rails generate hyrax:work Thesis`
class ThesisIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
   super.tap do |solr_doc|
     #solr_doc['my_custom_field_ssim'] = object.my_custom_property
     if ! object.file_sets.first.nil?
       solr_doc['all_text_timv'] = FileSet.find(object.representative_id).extracted_text.content if FileSet.find(object.representative_id).extracted_text.present?
     end
   end
  end
end
