# frozen_string_literal: true

module Murax
  # A common base class for all Murax jobs.
  # This allows downstream applications to manipulate all the Muraz jobs by
  # including modules on this class.
  class ApplicationJob < ActiveJob::Base
    include Sidekiq::Worker
    include SidekiqStatus::Worker
  end
end
