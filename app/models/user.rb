# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_uuid, on: :create

  has_many :webauthn_credentials, dependent: :destroy
  has_many :oauth_applications, as: :owner, dependent: :destroy
  has_many :user_oauth_applications, dependent: :destroy
  has_many :authorized_applications, through: :user_oauth_applications, source: :oauth_application
  has_one :webauthn_id, dependent: :delete

  validates :uuid, presence: true, uniqueness: true
  validates :email, presence: true, email_format: true

  def display_name
    return name if name.present?

    email
  end

  def authorize!(oauth_application)
    authorized_applications << oauth_application unless authorized?(oauth_application)
  end

  def authorized?(oauth_application)
    user_oauth_applications.where(oauth_application:).exists?
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end
end
