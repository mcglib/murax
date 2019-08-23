# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookPresenter < Hyrax::WorkShowPresenter
    delegate :title, :alternative_title, :rights, :contributor, :description, :language, :related_url,
             :creator, :note, :publisher, :abstract, :grant_number, :extent, :subject, :source, :license, 
             :date, :rtype, :orcidid,  :identifier, :relation, :bibliographic_citation,
             :use, to: :solr_document
  end
end
