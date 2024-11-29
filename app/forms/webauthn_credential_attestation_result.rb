# frozen_string_literal: true

class WebauthnCredentialAttestationResult
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :credential
  attribute :challenge
  attribute :user
  attribute :webauthn_id
  attribute :webauthn_credential
  attribute :registered_os
  attribute :registered_browser
  attribute :is_auto_upgrade

  validates :credential, :challenge, :user, :webauthn_id, :registered_os, :registered_browser, presence: true
  validate :verify_challenge

  def initialize(credential:, user:, challenge:, webauthn_id:, registered_os:, registered_browser:, is_auto_upgrade:)
    super
    @public_key_credential = WebAuthn::Credential.from_create(credential) if credential
  end

  def save
    return false if invalid?

    user.create_webauthn_id!(webauthn_id:) unless user.webauthn_id
    self.webauthn_credential = user.webauthn_credentials.create!(
      external_id: @public_key_credential.id,
      public_key: @public_key_credential.public_key,
      sign_count: @public_key_credential.sign_count,
      registered_browser:,
      registered_os:,
      last_used_at: Time.current
    )

    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def verify_challenge
    @public_key_credential&.verify(challenge, user_presence: !is_auto_upgrade, user_verification: !is_auto_upgrade)
  rescue WebAuthn::VerificationError => e
    errors.add(:base, "Verification failed (#{e.message}).")
  end
end
