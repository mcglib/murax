# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  # Generated form for Book
  class BookForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Book
    self.terms += [:title, :alternative_title, :rights, :creator, :note, :abstract, :grant_number, :extent,
                   :date,  :rights, :rtype, :orcidid, :relation, :bibliographic_citation ]
    self.terms -= [ :keyword, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:creator, :date, :rights, :rtype, :bibliographic_citation]
    self.required_fields -= [:keyword, :contact_email, :description]
    self.single_valued_fields = [:title,:creator, :rtype]
  end
end
