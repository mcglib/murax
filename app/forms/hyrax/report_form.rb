# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  # Generated form for Report
  class ReportForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    include Hyrax::NestedBehavior
    self.model_class = ::Report
    self.terms += [:title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
                   :nested_ordered_creator, :note,:abstract, :research_unit, :grant_number, :degree, :status,
                   :date,  :rights, :rtype, :extent, :orcidid, :relation, :report_number, :pmid, :bibliographic_citation]
    self.terms -= [:creator, :keyword, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:title, :nested_ordered_creator, :date, :rights, :rtype]
    self.required_fields -= [:rights_statement]
    self.single_valued_fields = [ :rtype, :title, :degree, :bibliographic_citation]

    def primary_terms
      [:title, :nested_ordered_creator, :date, :rights, :rtype  ] | super
    end

    def secondary_terms
      [:bibliographic_citation, :contributor, :description, :license,  :publisher, :subject, :language, :identifier, :related_url, :source, :alternative_title,
       :note, :abstract, :grant_number, :extent, :orcidid, :relation, :faculty, :department, :status, :local_affiliated_centre, :research_unit]
    end

    def self.build_permitted_params
      super + [
        {
          nested_ordered_creator_attributes: %i[id _destroy index creator],
        }
      ]
    end
  end
end
