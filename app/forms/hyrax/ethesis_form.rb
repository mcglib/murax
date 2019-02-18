# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  # Generated form for Ethesis
  class EthesisForm < Hyrax::Forms::WorkForm
    self.model_class = ::Ethesis
    self.terms += [:resource_type, :department]
    self.required_fields += [:department, :subject, :rights]
    self.required_fields -= [:keyword, :contact_email]
  end
end
