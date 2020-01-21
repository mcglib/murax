# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  # Generated form for Thesis
  class ThesisForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    include Hyrax::NestedBehavior
    self.model_class = ::Thesis
    self.terms += [:title, :degree, :institution, :faculty, :rights,
                   :nested_ordered_creator, :note, :extent, :abstract, :department,
                   :date, :date_accepted,  :rights, :rtype, :orcidid, :relation ]
    self.terms -= [ :keyword, :creator, :rights_statement, :date_created, :resource_type, :bibliographic_citation, :import_url, :relative_path, :based_near]
    self.required_fields += [:nested_ordered_creator,:date, :rights, :rtype, :department]
    self.required_fields -= [:keyword, :contact_email, :description, :faculty, :rights_statement]
    self.single_valued_fields = [:title, :rtype]

    def primary_terms
      [:title, :nested_ordered_creator,:date, :rights, :rtype, :department ] | super
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
