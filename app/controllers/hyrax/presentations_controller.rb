# Generated via
#  `rails generate hyrax:work Presentation`
module Hyrax
  # Generated controller for Presentation
  class PresentationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Presentation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PresentationPresenter
  end
end
