# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  # Generated form for Ethesis
  class EthesisForm < Hyrax::Forms::WorkForm
    
    class_attribute :single_value_fields
    self.model_class = ::Ethesis
    self.terms += [:resource_type, :department, :degree, :institution, :faculty, :description, :alternative_title, :rights,
                   :language_label, :creator, :contributor, :note, :abstract, :note, :publisher, :extent,
                   :date, :language, :rights, :license, :type, :orcidid, :related_url, :identifier, :relation ]
    self.required_fields += [:creator, :abstract, :publisher, :date, :subject, :institution, :degree,
                             :department, :faculty, :rights, :type, :identifier]
    self.required_fields -= [:keyword, :contact_email]
  end
end
