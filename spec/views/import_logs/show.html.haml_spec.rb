require 'rails_helper'

RSpec.describe "import_logs/show", type: :view do
  before(:each) do
    @import_log = assign(:import_log, ImportLog.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
