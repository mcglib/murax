# Generated via
#  `rails generate hyrax:work Presentation`
module Hyrax
  # Generated form for Presentation
  class PresentationForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Presentation
    self.terms += [:title,:alternative_title, :creator,:local_affiliated_centre, :department, :extent, 
                   :note, :abstract, :pmid, :research_unit, :grant_number,
                   :date,  :rights, :rtype, :orcidid, :relation,:faculty, :degree ]
    self.terms -= [ :keyword, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:creator, :date, :rights, :rtype]
    self.required_fields -= [:keyword, :contact_email, :description]
    self.single_valued_fields = [:title, :rtype]
  end
end
