# frozen_string_literal: true

module Users
  class WebauthnCredentialsController < ApplicationController
    def index
      @webauthn_credentials = current_user.webauthn_credentials
    end

    def options
      registration_options = WebauthnCredentialAttestationOptions.new(
        user: current_user
      )

      if registration_options.save
        session[:webauthn_credential_attestation] = {
          webauthn_id: registration_options.webauthn_id,
          challenge: registration_options.challenge
        }

        render status: :ok, json: { publicKey: registration_options }
      else
        render json: { message: registration_options.errors.full_messages.join('.'), error: true },
               status: :bad_request
      end
    end

    def create
      is_auto_upgrade = session.delete(:auto_upgrade)

      registration_result = WebauthnCredentialAttestationResult.new(
        credential: create_params,
        user: current_user,
        challenge: session.dig('webauthn_credential_attestation', 'challenge') || '',
        webauthn_id: session.dig('webauthn_credential_attestation', 'webauthn_id'),
        registered_os: request.os || 'Unknown',
        registered_browser: request.browser || 'Unknown',
        is_auto_upgrade:
      )

      if registration_result.save
        flash[:notice] = 'Passkey registered' unless is_auto_upgrade
        render json: {}, status: :ok
      else
        flash[:alert] = 'Failed to register passkey'
        render json: { error: true, message: registration_result.errors.full_messages.join('.') }, status: :bad_request
      end

      session.delete(:webauthn_credential_attestation)
    end

    def destroy
      webauthn_credential = current_user.webauthn_credentials.find_by(id: params[:id])

      if webauthn_credential&.destroy
        redirect_to user_webauthn_credentials_path(authorization_params), notice: 'Passkey deleted'
      else
        redirect_to user_webauthn_credentials_path(authorization_params), alert: 'Failed to delete passkey'
      end
    end

    private

    def create_params
      params.permit(
        'type',
        'id',
        'rawId',
        'authenticatorAttachment',
        'webauthn_credential' => [:id], # Permitting nested webauthn_credential
        'clientExtensionResults' => {}, # Permitting empty hash
        'response' => ['clientDataJSON', 'attestationObject', { 'transports' => [] }] # Allowing transports as an array
      )
    end
  end
end
