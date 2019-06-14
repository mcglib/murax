# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  # Generated form for Report
  class ReportForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Report
        self.terms += [:title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
                   :creator, :note,:abstract, :research_unit, :grant_number, :degree,
                   :date,  :rights, :rtype, :orcidid, :relation, :report_number, :pmid, :license ]
    self.terms -= [ :keyword, :rights_statement,:status, :date_created,:bibliographic_citation, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:creator, :date, :rights, :rtype]
    self.single_valued_fields = [:alternative_title, :creator, :contributor, :description, :abstract, :note, 
                                 :date, :source, :department, :license,
                                 :faculty, :rights, :orcidid, :related_url]
  end
end
