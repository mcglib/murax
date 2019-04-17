# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  class ArticlePresenter < Hyrax::WorkShowPresenter
    delegate :abstract,  :alternative_title, :description, :creator, :bibliographic_citation, :department,:source
             :faculty, :rights, :rtype, :date, :orcidid, :contributor, :publisher, :local_affiliated_centre,
             :subject, :license_label, :note, :language, :relation, :pmid, :research_unit, :grant_number, :status, 
             :use, to: :solr_document

  end
end
