require 'rails_helper'

RSpec.describe "import_logs/new", type: :view do
  before(:each) do
    assign(:import_log, ImportLog.new())
  end

  it "renders new import_log form" do
    render

    assert_select "form[action=?][method=?]", import_logs_path, "post" do
    end
  end
end
