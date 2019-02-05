# Generated via
#  `rails generate hyrax:work Poster`
module Hyrax
  # Generated form for Poster
  class PosterForm < Hyrax::Forms::WorkForm
    self.model_class = ::Poster
    self.terms += [:resource_type]
  end
end
