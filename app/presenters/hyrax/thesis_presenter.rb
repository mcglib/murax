# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  class ThesisPresenter < Hyrax::WorkShowPresenter
    delegate :abstract,  :alternative_title, :description,
             :degree,:department, :degree, :faculty, :rights,:rtype,:date,:institution, :orcidid,
             :subject, :license_label, :note, :place_of_publication, :language, :relation,
             :use, to: :solr_document
  end
end
