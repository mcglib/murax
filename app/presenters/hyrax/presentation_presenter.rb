# Generated via
#  `rails generate hyrax:work Presentation`
module Hyrax
  class PresentationPresenter < Hyrax::WorkShowPresenter
    delegate :title,:alternative_title, :creator, :contributor, :local_affiliated_centre, :department, :subject, :extent, :license,
             :note, :publisher, :abstract, :pmid, :research_unit, :grant_number, :description, :source, :language,
             :date,  :rights, :rtype, :orcidid,  :identifier, :relation, :related_url, :faculty, :degree,
             :use, to: :solr_document
  end
end
