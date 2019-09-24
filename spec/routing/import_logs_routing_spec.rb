require "rails_helper"

RSpec.describe ImportLogsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/import_logs").to route_to("import_logs#index")
    end

    it "routes to #new" do
      expect(:get => "/import_logs/new").to route_to("import_logs#new")
    end

    it "routes to #show" do
      expect(:get => "/import_logs/1").to route_to("import_logs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/import_logs/1/edit").to route_to("import_logs#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/import_logs").to route_to("import_logs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/import_logs/1").to route_to("import_logs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/import_logs/1").to route_to("import_logs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/import_logs/1").to route_to("import_logs#destroy", :id => "1")
    end
  end
end
