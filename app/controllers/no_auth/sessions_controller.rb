# frozen_string_literal: true

module NoAuth
  class SessionsController < Devise::SessionsController
    before_action :store_authorization_params, only: :new # rubocop:disable Rails/LexicallyScopedActionFilter

    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    def destroy
      BackchannelLogoutService.perform_all(current_user)

      super
    end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end

    private

    def after_sign_in_path_for(user)
      return webauthn_auto_upgrade_path if user.webauthn_credentials.empty? && cookies[:icca].present?

      super
    end

    def store_authorization_params
      session[:authorization_params] = authorization_params
    end
  end
end
