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
      pids =  get_pids(pid)

      # get the user
      depositor = User.find(user)
      # Create the batch
      batch = Batch.new({:no => pids.count, :name => name, :started => Time.now,
                         :finished => Time.now, user: depositor})
      batch.save!
      byebug
      ImportDigitoolPidWorker.perform_async(batch.id, pids, depositor) if pids.present?
      #flash[:message] = "You did it! A job with job id has been queued. You will receive a notification once the job is complete"
      true
    end

    def get_pids(pid_string)
      pids = []
      pids = pid_string.split(',').map{ |s| s.to_i } # first argument
      pids
    end
  end
end
