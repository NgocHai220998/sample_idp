# frozen_string_literal: true

# app/services/backchannel_logout_service.rb
class BackchannelLogoutService
  extend HttpRequestable
  extend Jwt::RequestAuthenticator

  def self.perform_all(user)
    user.authorized_applications.each do |application|
      next unless application.backchannel_logout_uri

      send_logout_request(user, application)
    end
  end

  def self.perform(user, client_id)
    return unless user

    application = user.authorized_applications.find_by(uid: client_id)
    return unless application&.backchannel_logout_uri

    send_logout_request(user, application)
  end

  def self.send_logout_request(user, application)
    token = generate_jwt_token(user.sub, application.uid)
    headers = { 'user_agent' => 'Sample ID' }

    begin
      response = post_request(application.backchannel_logout_uri, { logout_token: token }, headers)
      Rails.logger.info("Backchannel logout successful for application #{application.id}: #{response}")
    rescue StandardError => e
      Rails.logger.error("Failed to send backchannel logout for application #{application.id}: #{e.message}")
    end
  end
end
