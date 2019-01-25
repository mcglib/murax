# Generated via
#  `rails generate hyrax:work Poster`
module Hyrax
  # Generated controller for Poster
  class PostersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Poster

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PosterPresenter
  end
end
