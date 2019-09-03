# frozen_string_literal: true

module Murax
  # presenter behavior for default
  module DefaultPresenterBehavior
    extend ActiveSupport::Concern
    included do
      delegate :nested_ordered_creator,
               :nested_ordered_creator_label,
               :title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
               :note,:abstract, :research_unit, :grant_number, :degree,
               :date,  :rights, :rtype, :extent, :orcidid, :relation, :report_number, :pmid,
               :use,  to: :solr_document
    end
  end
end
