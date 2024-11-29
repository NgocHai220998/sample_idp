# frozen_string_literal: true

class WebauthnId < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :webauthn_id, presence: true, uniqueness: true
end
