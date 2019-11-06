require 'rails_helper'
RSpec.describe ImportDigitoolPidWorker, type: :worker do
  pending "add some examples to (or delete) #{__FILE__}"
  test 'that pids is imported' do
    ImportDigitoolPidWorker.perform_async("12345", "dev.library@mcgill.ca")
    # literally no idea what to assert here...
    # assert
  end
end
