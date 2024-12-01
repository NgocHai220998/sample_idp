# frozen_string_literal: true

class OauthApplication < Doorkeeper::Application
  belongs_to :owner, class_name: 'User'
  has_many :user_oauth_applications, dependent: :destroy
  has_many :users, through: :user_oauth_applications
end
