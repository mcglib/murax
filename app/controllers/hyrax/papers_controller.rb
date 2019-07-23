# Generated via
#  `rails generate hyrax:work Paper`
module Hyrax
  # Generated controller for Paper
  class PapersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Paper

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PaperPresenter
  end
end
