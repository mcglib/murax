module Hyrax
  module Admin
    class ImportLogsController < ApplicationController
      before_action :require_permissions
      with_themed_layout 'dashboard'
      before_action :require_permissions
      before_action :set_import_log, only: [:show, :edit, :update, :destroy]

      def index
        @batch = Batch.includes(:import_log).find(params[:batch_id]) #ImportLog.all
        @import_logs = @batch.import_log.all
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.import_logs.header', batch_id: @batch.id), batches_path
        @presenter = ImportLogsPresenter.new
      end

      def destroy
      end
      # GET /import_logs/1
      # GET /import_logs/1.json
      def show
        @batch = @import_log.batch
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.import_logs.header', batch_id: @batch.id), batches_path
      end


      def create
        @import_log = ImportLog.new(import_log_params)

        respond_to do |format|
          if @import_log.save
            format.html { redirect_to @import_log, notice: 'Import log was successfully created.' }
            format.json { render :show, status: :created, location: @import_log }
          else
            format.html { render :new }
            format.json { render json: @import_log.errors, status: :unprocessable_entity }
          end
        end
      end

      private

        def require_permissions
          authorize! :read, :admin_dashboard
        end
        # Use callbacks to share common setup or constraints between actions.
        def set_import_log
          @import_log = ImportLog.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def import_log_params
          params.fetch(:import_log, {})
        end
        def require_permissions
          authorize! :read, :admin_dashboard
        end
    end
  end
end
