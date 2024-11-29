# frozen_string_literal: true

class WebauthnCredential < ApplicationRecord
  belongs_to :user
end
