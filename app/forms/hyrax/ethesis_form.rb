# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  # Generated form for Ethesis
  class EthesisForm < Hyrax::Forms::WorkForm
    self.model_class = ::Ethesis
    self.terms += [:resource_type, :contact_email, :contact_phone, :department]
    self.required_fields += [:department, :contact_email]
    self.required_fields -= [:keyword, :rights]
  end
end
