require 'rails_helper'

RSpec.describe "import_logs/edit", type: :view do
  before(:each) do
    @import_log = assign(:import_log, ImportLog.create!())
  end

  it "renders the edit import_log form" do
    render

    assert_select "form[action=?][method=?]", import_log_path(@import_log), "post" do
    end
  end
end
