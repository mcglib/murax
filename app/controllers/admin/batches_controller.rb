module Admin
  class BatchesController < ApplicationController
    with_themed_layout 'dashboard'
    before_action :require_permissions
    before_action :set_batch, only: [:show, :edit, :update, :destroy]

    # GET /batches
    # GET /batches.json
    def index
      @batches = Batch.all
      add_breadcrumb t(:'hyrax.controls.home'), root_path
    end

    # GET /batches/1
    # GET /batches/1.json
    def show
      @import_logs = @batch.import_log
    end

    # GET /batches/import
    def import
      @form = Murax::ImportPidForm.new
      @users = User.all
    end

    # POST /batches/ingest
    def ingest
      @form = Murax::ImportPidForm.new(import_pid_form_params)
      respond_to do |format|
        if @form.submit
            format.html { redirect_to import_admin_batches_path, notice: "Thank you for importing,
                          a job with the pids #{@form.pid} has been created and you will be notified on completion" }
            format.json { render :import, status: :created, location: @form }
        else
          format.html { render :import }
          format.json { render json: @form.errors, status: :unprocessable_entity }
        end
      end
      #
      # end ingesting
      # validate the form
    end

    


    # GET /batches/new
    def new
      @batch = Batch.new
    end

    # GET /batches/1/edit
    def edit
    end

    # POST /batches
    # POST /batches.json
    def create
      @batch = Batch.new(batch_params)

      respond_to do |format|
        if @batch.save
          format.html { redirect_to @batch, notice: 'Batch was successfully created.' }
          format.json { render :show, status: :created, location: @batch }
        else
          format.html { render :new }
          format.json { render json: @batch.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /batches/1
    # PATCH/PUT /batches/1.json
    def update
      respond_to do |format|
        if @batch.update(batch_params)
          format.html { redirect_to @batch, notice: 'Batch was successfully updated.' }
          format.json { render :show, status: :ok, location: @batch }
        else
          format.html { render :edit }
          format.json { render json: @batch.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /batches/1
    # DELETE /batches/1.json
    def destroy
      @batch.destroy
      respond_to do |format|
        format.html { redirect_to batches_url, notice: 'Batch was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_batch
        @batch = Batch.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def batch_params
        params.fetch(:batch, {})
      end

      def import_pid_form_params
        params.require(:murax_import_pid_form).permit(:name, :user, :pid)
      end

      def require_permissions
        authorize! :read, :admin_dashboard
      end
  end
end
