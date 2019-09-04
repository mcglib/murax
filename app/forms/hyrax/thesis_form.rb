# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  # Generated form for Thesis
  class ThesisForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Thesis
    self.terms += [:title, :degree, :institution, :faculty, :rights,
                   :creator, :note, :extent, :abstract, :department, 
                   :date,  :rights, :subject, :rtype, :orcidid,  :identifier, :relation, :author_order ]
    self.terms -= [ :keyword, :rights_statement, :date_created, :resource_type, :bibliographic_citation, :import_url, :relative_path, :based_near]
    self.required_fields += [:creator,:date, :subject, :rights, :rtype, :identifier, :department]
    self.required_fields -= [:keyword, :contact_email, :description, :faculty, :rights_statement]
    self.single_valued_fields = [:title, :rtype]

  end
end
