# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  class EthesisPresenter < Hyrax::WorkShowPresenter
    delegate :abstract,  :alternative_title, :Description,
             :degree, :institution, :department,
             :subject, :language_label, :license_label, :note, :place_of_publication,
             :use, to: :solr_document
  end
end
