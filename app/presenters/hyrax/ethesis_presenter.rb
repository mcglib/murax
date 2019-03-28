# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  class EthesisPresenter < Hyrax::WorkShowPresenter
    delegate :abstract,  :alternative_title, :description,
             :degree,:department, :degree, :faculty, :rights,:rtype,:date,:institution, :orcidid,
             :subject, :language_label, :license_label, :note, :place_of_publication,
             :use, to: :solr_document
  end
end
