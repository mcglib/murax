# frozen_string_literal: true

module Murax
  class ImportPidForm
    include ActiveModel::Model
    attr_accessor :name, :pid, :user
    validates :name, :user, :pid, presence: true
    def submit
      return false if invalid?
      # send acknowledgement reply, and admin notification emails, etc
      # start ingesting
      # create a logger
      byebug
      import_service = Migration::Services::ImportService.new({:pid => pid, :admin_set => admin_set}, user, logger)
      true
    end
  end
end
