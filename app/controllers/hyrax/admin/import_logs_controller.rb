module Hyrax
  module Admin
    class ImportLogsController < ApplicationController
      before_action :require_permissions
      with_themed_layout 'dashboard'

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.import_logs.header'), hyrax.admin_workflow_roles_path
        @presenter = ImportLogsPresenter.new
      end

      def destroy
      end

      def create
        authorize! :create, Sipity::WorkflowResponsibility
        form = Forms::WorkflowResponsibilityForm.new(params[:sipity_workflow_responsibility])
        begin
          form.save!
        rescue ActiveRecord::RecordNotUnique
          logger.info "Not unique *****\n\n\n"
        end
        redirect_to admin_workflow_roles_path
      end

      private

        def require_permissions
          authorize! :read, :admin_dashboard
        end
    end
  end
end
