# frozen_string_literal: true

module Murax
  # presenter behavior for default
  module DefaultPresenterBehavior
    extend ActiveSupport::Concern
    included do
      delegate :nested_ordered_creator, :nested_ordered_creator_label,
               :title, :alternative_title, :contributor, :local_affiliated_centre, :department, :subject, :extent, :license,
               :note, :publisher, :abstract, :pmid, :research_unit, :grant_number, :status, :description, :source, :language,
               :date,  :rights, :rtype, :orcidid, :identifier, :bibliographic_citation, :relation, :report_number, :related_url, :faculty, :degree, :author_order,
               :use,  to: :solr_document
    end
  end
end
