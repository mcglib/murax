# frozen_string_literal: true

# reindexes everything
class ReindexEverythingJob < Murax::ApplicationJob
  queue_as :default
  def perform

  end
end
