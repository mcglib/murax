module Admin
  class ImportLogsController < ApplicationController
    before_action :require_permissions
    with_themed_layout 'dashboard'
    before_action :set_import_log, only: [:show, :edit, :update, :destroy]

    # GET /import_logs
    # GET /import_logs.json
    def index
      @batch = Batch.includes(:import_log).find(params[:batch_id]) #ImportLog.all
      @import_logs = @batch.import_log.all
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.admin.import_logs.header', batch_id: @batch.id), batches_path
    end

    # GET /import_logs/1
    # GET /import_logs/1.json
    def show
      @batch = @import_log.batch
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.admin.import_logs.header', batch_id: @batch.id), batches_path
    end

    # GET /import_logs/new
    def new
      @import_log = ImportLog.new
    end

    # GET /import_logs/1/edit
    def edit
    end

    # POST /import_logs
    # POST /import_logs.json
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

    # PATCH/PUT /import_logs/1
    # PATCH/PUT /import_logs/1.json
    def update
      respond_to do |format|
        if @import_log.update(import_log_params)
          format.html { redirect_to @import_log, notice: 'Import log was successfully updated.' }
          format.json { render :show, status: :ok, location: @import_log }
        else
          format.html { render :edit }
          format.json { render json: @import_log.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /import_logs/1
    # DELETE /import_logs/1.json
    def destroy
      @import_log.destroy
      respond_to do |format|
        format.html { redirect_to import_logs_url, notice: 'Import log was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
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
