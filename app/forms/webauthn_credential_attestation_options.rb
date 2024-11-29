# frozen_string_literal: true

class WebauthnCredentialAttestationOptions
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user
  attribute :webauthn_id
  attr_reader :options

  delegate :challenge, :as_json, to: :options

  validates :webauthn_id, presence: true

  def save
    return false if invalid?

    @options ||= WebAuthn::Credential.options_for_create(
      user: {
        id: webauthn_id,
        name: user.email,
        display_name: user.display_name
      },
      exclude: user.webauthn_credentials.pluck(:external_id),
      authenticator_selection: {
        authenticator_attachment: 'platform',
        user_verification: 'required',
        resident_key: 'required'
      }
    )
    true
  end

  def webauthn_id
    @webauthn_id ||= user&.webauthn_id&.webauthn_id || WebAuthn.generate_user_id
  end
end
