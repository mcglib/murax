# Generated via
#  `rails generate hyrax:work Paper`
module Hyrax
  class PaperPresenter < Hyrax::WorkShowPresenter
    delegate :title,:alternative_title, :creator, :contributor, :local_affiliated_centre, :department, :subject, :extent, 
             :note, :publisher, :abstract, :pmid, :research_unit, :grant_number, :status, :description, :source, :language,
             :date,  :rights, :rtype, :orcidid,  :identifier, :relation, :bibliographic_citation, :related_url, :faculty, :degree,
             :use, to: :solr_document
  end
end
