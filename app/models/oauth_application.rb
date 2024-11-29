# frozen_string_literal: true

class OauthApplication < Doorkeeper::Application
  belongs_to :owner, class_name: 'User'
end
