# frozen_string_literal: true

module Hyrax
  # behavior for nested propeerties

  module NestedBehavior
    extend ActiveSupport::Concern

    included do
      delegate :nested_ordered_creator_attributes=, to: :model

      def initialize_fields
        model.nested_ordered_creator.build({index:'0'})
        super
      end
    end
  end
end
