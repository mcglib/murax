# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    include Hyrax::NestedBehavior
    self.model_class = ::Article
    self.terms += [:title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
                   :nested_ordered_creator, :note, :abstract, :pmid, :research_unit, :grant_number, :status, :extent,
                   :date,  :rights, :rtype, :orcidid, :relation, :bibliographic_citation]
    self.terms -= [ :keyword, :creator, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:nested_ordered_creator, :date, :rights, :rtype, :bibliographic_citation]
    self.required_fields -= [:keyword, :contact_email, :description, :rights_statement]
    self.single_valued_fields = [:title, :rtype ]

    def primary_terms
      [:title, :nested_ordered_creator, :date, :rights, :rtype, :bibliographic_citation ] | super
    end

    def secondary_terms
      [:alternative_title, :orcidid, :license, :publisher, :pmid, :identifier, :source, :language,  :abstract, :subject, :contributor, :faculty, :department, :local_affiliated_centre, :research_unit, :status, :grant_number, :related_url, :note, :description, :extent, :relation]
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
