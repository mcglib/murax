# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    class_attribute :single_value_fields
    self.model_class = ::Article
    self.terms += [:title, :faculty, :alternative_title, :rights, :local_affiliated_centre, :department,
                   :creator, :note, :publisher, :abstract, :pmid, :research_unit, :grant_number, :status,
                   :date,  :rights, :subject, :rtype, :orcidid,  :identifier, :relation, :bibliographic_citation ]
    self.terms -= [ :keyword, :rights_statement, :date_created, :resource_type,:import_url, :relative_path, :based_near]
    self.required_fields += [:creator, :date, :rights, :rtype, :bibliographic_citation]
    self.required_fields -= [:keyword, :contact_email, :description]

    def self.multiple?(field)
      if [:title, :bibliographic_citation].include? field.to_sym
        false 
      else 
        super
      end


  end
end
