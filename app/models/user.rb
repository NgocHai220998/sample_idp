# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_uuid, on: :create

  has_many :webauthn_credentials, dependent: :destroy
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_one :webauthn_id, dependent: :delete

  validates :uuid, presence: true, uniqueness: true
  validates :email, presence: true, email_format: true

  def display_name
    return name if name.present?

    email
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end
end
