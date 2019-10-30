module Admin
  class BatchesController < ApplicationController
    with_themed_layout 'dashboard'
    before_action :require_permissions
    before_action :set_batch, only: [:show, :edit, :update, :destroy]

    # GET /batches
    # GET /batches.json
    def index
      byebug
      @batches = Batch.all

      add_breadcrumb t(:'hyrax.controls.home'), root_path
    end

    # GET /batches/1
    # GET /batches/1.json
    def show
      @import_logs = @batch.import_log
    end

    def import
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
      def require_permissions
        authorize! :read, :admin_dashboard
      end
  end
end
