require 'rails_helper'

RSpec.describe "import_logs/index", type: :view do
  before(:each) do
    assign(:import_logs, [
      ImportLog.create!(),
      ImportLog.create!()
    ])
  end

  it "renders a list of import_logs" do
    render
  end
end
