# Generated via
#  `rails generate hyrax:work Paper`
module Hyrax
  # Generated form for Paper
  class PaperForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    include Hyrax::NestedBehavior
    self.model_class = ::Paper
    self.terms += [:title,:alternative_title, :nested_ordered_creator,:local_affiliated_centre, :department, :extent, 
                   :note, :abstract, :pmid, :research_unit, :grant_number,
                   :date,  :rights, :rtype, :orcidid, :relation,:faculty, :degree]
    self.terms -= [ :keyword, :creator, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:title, :nested_ordered_creator, :date, :rights, :rtype]
    self.required_fields -= [:keyword, :contact_email, :description]
    self.single_valued_fields = [:rtype, :title, :degree]

    def primary_terms
      [:title, :nested_ordered_creator, :date, :rights, :rtype  ] | super
    end

    def self.build_permitted_params
      super + [
        :language_select,
        {
          nested_ordered_creator_attributes: %i[id _destroy index creator],
        }
      ]
    end
  end
end
