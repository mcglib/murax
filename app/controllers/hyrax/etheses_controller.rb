# Generated via
#  `rails generate hyrax:work Ethesis`
module Hyrax
  # Generated controller for Ethesis
  class EthesesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Ethesis

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::EthesisPresenter
  end
end
