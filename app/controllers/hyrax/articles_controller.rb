# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated controller for Article
  class ArticlesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Murax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Article

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ArticlePresenter
  end
end
