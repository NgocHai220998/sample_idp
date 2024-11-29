# frozen_string_literal: true

class WebauthnAssertionOptions
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user
  attribute :allowed_credentials
  attr_reader :options

  delegate :allow, :challenge, :as_json, to: :options

  def save
    return false if invalid?

    arguments = { user_verification: :required }
    arguments.merge!(allow: allowed_credentials) if user
    @options = WebAuthn::Credential.options_for_get(**arguments)

    true
  end

  private

  def allowed_credentials
    @allowed_credentials ||= user&.webauthn_credentials&.pluck(:external_id)
  end
end
