# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  class EthesisPresenter < Hyrax::WorkShowPresenter
    delegate :abstract,  :alternative_title, 
             :degree, :institution, :department,
             :subject, :language_label, :license_label, :note, :place_of_publication,
             :resource_type, :rights_statement_label, :use, to: :solr_document
  end
end
