# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  # Generated form for Book
  class BookForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    include Hyrax::NestedBehavior
    self.model_class = ::Book
    self.terms += [:title, :alternative_title, :rights, :nested_ordered_creator, :note, :abstract, :grant_number, :extent,
                   :date,  :rights, :rtype, :orcidid, :relation, :bibliographic_citation ]
    self.terms -= [ :keyword, :creator, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:nested_ordered_creator, :date, :rights, :rtype, :bibliographic_citation]
    self.required_fields -= [:keyword, :contact_email, :description, :rights_statement]
    self.single_valued_fields = [:title, :rtype]

    def primary_terms
      [:title, :nested_ordered_creator, :date, :rights, :rtype, :bibliographic_citation ] | super
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
