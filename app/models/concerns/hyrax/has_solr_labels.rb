# frozen_string_literal: true

module Hyrax
  # solr label ops
  module HasSolrLabels
    extend ActiveSupport::Concern
    
    included do
      def to_solr(solr_doc = {})
        super.tap do |doc|
          ordered_creator_labels = nested_ordered_creator.map { |i| (i.instance_of? NestedOrderedCreator) ? "#{i.creator.first}$#{i.index.first}" : i }.select(&:present?)
          creator_labels = nested_ordered_creator.map { |i| (i.instance_of? NestedOrderedCreator) ? "#{i.creator.first}" : i }.select(&:present?).uniq
         
          labels = [ {label: 'nested_ordered_creator_label', data: ordered_creator_labels} ]

          labels.each do |label_set|
            doc[ActiveFedora.index_field_mapper.solr_name(label_set[:label], :symbol)] = label_set[:data]
            doc[ActiveFedora.index_field_mapper.solr_name(label_set[:label], :stored_searchable)] = label_set[:data]
          end
       
          doc['creator_sim'] = creator_labels
        end
      end
    end
  end
end
