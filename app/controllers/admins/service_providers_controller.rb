# frozen_string_literal: true

module Admins
  class ServiceProvidersController < ApplicationController
    layout 'doorkeeper/admin'

    before_action :set_service_provider, only: %i[show edit update destroy]

    def index
      @service_providers = ServiceProvider.all
    end

    def show; end

    def new
      @service_provider = ServiceProvider.new
    end

    def edit; end

    def create
      @service_provider = ServiceProvider.new(service_provider_params)

      if @service_provider.save
        redirect_to @service_provider, notice: 'Service provider was successfully created.'
      else
        render :new
      end
    end

    def update
      if @service_provider.update(service_provider_params)
        redirect_to @service_provider, notice: 'Service provider was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @service_provider.destroy
      redirect_to service_providers_url, notice: 'Service provider was successfully destroyed.'
    end

    private

    def set_service_provider
      @service_provider = ServiceProvider.find(params[:id])
    end

    def service_provider_params
      params.require(:service_provider).permit(:name, :metadata_url, :response_hosts, :fingerprint)
    end
  end
end
