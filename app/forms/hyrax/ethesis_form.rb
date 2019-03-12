# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  # Generated form for Ethesis
  class EthesisForm < Hyrax::Forms::WorkForm
    
    class_attribute :single_value_fields
    self.model_class = ::Ethesis
    self.terms += [:title, :department, :degree, :institution, :faculty,:alternative_title, :rights,
                   :creator, :note, :publisher, :extent, :Description, :abstract, 
                   :date,  :rights, :subject, :rtype, :orcidid,  :identifier, :relation ]
    self.terms -= [:description, :keyword, :rights_statement, :date_created, :source, :resource_type, :bibliographic_citation, :import_url, :relative_path]

    self.required_fields += [:creator, :abstract,  :publisher, :date, :subject, :institution, :degree,
                             :department, :faculty, :rights, :rtype, :identifier]
    self.required_fields -= [:keyword, :contact_email, :description]
  end
end
