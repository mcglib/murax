# encoding: utf-8

class ErrorsController < ApplicationController
  #skip_before_action :authenticate_user!

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: { message: "Not Found" }, status: 404 }
      format.js   { render json: { message: "Not Found" }, status: 404 }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render status: 422 }
      format.json { render json: { message: "Invalid entity" }, status: 422 }
      format.js   { render json: { message: "Invalid entity" }, status: 422 }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: 500 }
      format.json { render json: { message: "Internal server error" }, status: 500 }
    end
  end
end
