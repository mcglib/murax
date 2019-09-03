# frozen_string_literal: true

module Murax
  # nested ordered property ops
  module HasNestedOrderedProperties
    extend ActiveSupport::Concern

    included do
      def creator
        nested_ordered_creator.present? ? ordered_creators : super
      end

      def ordered_creators
        sort_creators_by_index.map { |creators| creators.first }
      end

      def sort_creators_by_index
        validate_creators.sort_by { |creators| creators.second.to_i }
      end

      def validate_creators
        nested_ordered_creator.select { |i| (i.instance_of? NestedOrderedCreator) && (i.index.first.present? && i.creator.first.present?) && (i.index.first.instance_of? String) && (i.creator.first.instance_of? String) }
          .map { |i| (i.instance_of? NestedOrderedCreator) ? [i.creator.first, i.index.first] : [i] }
          .select(&:present?)
      end
    end
  end
end


