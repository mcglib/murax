# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.model_class = ::Article
    self.terms += [:title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
                   :creator, :note, :abstract, :pmid, :research_unit, :grant_number, :status, :extent,
                   :date,  :rights, :rtype, :orcidid, :relation, :bibliographic_citation ]
    self.terms -= [ :keyword, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:creator, :date, :rights, :rtype, :bibliographic_citation]
    self.required_fields -= [:keyword, :contact_email, :description, :rights_statement]
    self.single_valued_fields = [:title, :rtype ]
  end
end
