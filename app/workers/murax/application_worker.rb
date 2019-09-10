module Murax
  class ApplicationWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker # enables job status tracking
  end
end
