require 'rails_helper'
RSpec.describe ImportDigitoolPidWorker, type: :worker do
  pending "add some examples to (or delete) #{__FILE__}"
  test 'that pids is imported' do
    ImportDigitoolPidWorker.perform_async("12345", "dev.library@mcgill.ca")
    # literally no idea what to assert here...
    # assert
  end
  test 'that job is pushed to queue' do
    assert_equal 0, ImportDigitoolPidWorker.jobs.size
    ImportDigitoolPidWorker.perform_async("12345", test@test.com", "hello")
    assert_equal 1, ImportDigitoolPidWorker.jobs.size
  end
end
