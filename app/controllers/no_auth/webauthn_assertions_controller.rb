# frozen_string_literal: true

module NoAuth
  class WebauthnAssertionsController < ApplicationController
    before_action :require_stored_credential, only: :create

    def options
      session.delete(:current_authentication)

      authentication_options = WebauthnAssertionOptions.new(
        user: nil
      )

      if authentication_options.save
        session[:current_authentication] = {
          allow: authentication_options.allow,
          authentication_challenge: authentication_options.challenge
        }
        render status: :ok, json: { mediation: :conditional, publicKey: authentication_options }
      else
        render json: { message: authentication_options.errors.full_messages.join('.'), error: true },
               status: :bad_request
      end
    end

    def create
      if authenticated_credential.present?
        user = authenticated_credential.user
        sign_in(user, method: 'Passkey')

        client_params = session.delete(:authorization_params)

        if client_params['client_id'].present?
          render json: { redirectPath: oauth_authorization_path(client_params) }, status: :ok
        else
          flash[:notice] = 'Successfully authenticated with passkey'
          render json: { redirectPath: root_path(authorization_params) }, status: :ok
        end
      else
        flash[:alert] = 'Invalid credentials'
      end
    end

    private

    def create_params
      params.require(:authenticatorResponse)
    end

    def webauthn_credential
      @webauthn_credential ||= WebAuthn::Credential.from_get(create_params)
    end

    def stored_credential
      @stored_credential ||= WebauthnCredential.find_by(external_id: webauthn_credential.id)
    end

    def require_stored_credential
      return if stored_credential

      flash[:alert] = 'This passkey is no longer available. Please authenticate with the password.'
      render json: { redirectPath: new_user_session_path(authorization_params) }, status: :unauthorized
    end

    def valid_webauthn_assertion?
      current_authentication = session.delete(:current_authentication)
      return false if current_authentication.blank?

      return false if current_authentication[:allow]&.exclude?(webauthn_credential.id)

      webauthn_credential.verify(
        current_authentication['authentication_challenge'],
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count,
        user_verification: true
      )
    rescue WebAuthn::UserVerifiedVerificationError
      false
    end

    def authenticated_credential
      @authenticated_credential ||= if valid_webauthn_assertion?
                                      # Update the stored credential sign count with the value from `webauthn_credential.sign_count`
                                      stored_credential.update!(sign_count: webauthn_credential.sign_count, last_used_at: Time.current)
                                      stored_credential
                                    else
                                      false
                                    end
    end
  end
end
