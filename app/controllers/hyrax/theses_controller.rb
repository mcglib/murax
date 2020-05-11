# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  # Generated controller for Thesis
  class ThesesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Murax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Thesis
   
    #Set the default values only for Thesis worktype.
    def new 
      curation_concern.publisher = ['McGill University']
      super
    end

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ThesisPresenter
  end
end
