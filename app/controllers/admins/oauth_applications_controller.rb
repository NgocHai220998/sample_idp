# frozen_string_literal: true

module Admins
  class OauthApplicationsController < Doorkeeper::ApplicationsController
    before_action :ensure_application_owner, only: %i[show edit update destroy] # rubocop:disable Rails/LexicallyScopedActionFilter

    # NOTE: those actions are used implicitly.
    # def show; super; end
    # def new; super; end
    # def edit; super; end

    def index
      @applications = OauthApplication.where(owner: current_user)
    end

    def create
      @application = OauthApplication.new(application_params)
      @application.owner = current_user
      if @application.save
        flash[:notice] = 'Application created.'

        redirect_to oauth_application_path(@application)
      else
        render :new
      end
    end

    # def destroy; end

    # def update; end

    private

    def ensure_application_owner
      return if @application.owner == current_user

      redirect_to oauth_applications_path
    end

    def application_params
      params.require(:oauth_application).permit(
        :name,
        :redirect_uri,
        :skip_authorization,
        :confidential,
        :scopes
      )
    end
  end
end
