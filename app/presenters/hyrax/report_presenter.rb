# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  class ReportPresenter < Hyrax::WorkShowPresenter
    delegate :title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
             :creator, :note,:abstract, :research_unit, :grant_number, :degree,
             :date,  :rights, :rtype, :extent, :orcidid, :relation, :report_number, :pmid
             :use, to: :solr_document
  end
end
