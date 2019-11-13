# frozen_string_literal: true

module Murax
  # A common base class for all Murax jobs.
  # This allows downstream applications to manipulate all the Murax jobs by
  # including modules on this class.
  class ApplicationJob
    include Sidekiq::Worker
  end
end
