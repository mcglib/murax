# frozen_string_literal: true

module Hyrax
  # default controller
  class DefaultsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Murax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    self.curation_concern_type = Default

    # Use this line if you want to use a custom presenter
    self.show_presenter = DefaultPresenter
  end
end
