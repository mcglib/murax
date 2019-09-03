# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  # Generated form for Report
  class ReportForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    include Murax::NestedBehavior
    self.model_class = ::Report
    self.terms += [:title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
                   :nested_ordered_creator, :note,:abstract, :research_unit, :grant_number, :degree,
                   :date,  :rights, :rtype, :extent, :orcidid, :relation, :report_number, :pmid, :author_order ]
    self.terms -= [:identifier, :creator, :keyword, :rights_statement,:status, :date_created,:bibliographic_citation, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:nested_ordered_creator, :date, :rights, :rtype]
    self.required_fields -= [:rights_statement]
    self.single_valued_fields = [ :rtype, :title, :degree]

    def primary_terms
      [:nested_ordered_creator] 
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
