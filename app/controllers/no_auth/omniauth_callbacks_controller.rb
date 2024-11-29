# frozen_string_literal: true

module NoAuth
  # TODO: Need to refactor later
  class OmniauthCallbacksController < ApplicationController
    include HttpRequestable

    before_action :verify_state, only: %i[callback]

    def new
      redirect_to authorization_url, allow_other_host: true
    end

    def callback
      token_response = post_request(ENV['GITHUB_TOKEN_URI'], {
                                      grant_type: 'authorization_code',
                                      code: params[:code],
                                      redirect_uri: ENV['GITHUB_REDIRECT_URI'],
                                      client_id: ENV['GITHUB_CLIENT_ID'],
                                      client_secret: ENV['GITHUB_CLIENT_SECRET']
                                    })

      access_token = token_response['access_token']
      user_info = get_request(ENV['GITHUB_USER_URI'], { 'Authorization' => "Bearer #{access_token}" })

      user = User.find_or_create_by!(email: "#{user_info['id']}@github.com") do |u|
        u.provider = 'Github'
        u.password = Devise.friendly_token[0, 20]
        u.uid = user_info['id']
        u.name = user_info['name'] || user_info['id']
      end

      sign_in(user, method: 'Github')

      client_params = session.delete(:authorization_params)

      if client_params['client_id'].present?
        redirect_to oauth_authorization_path(client_params)
      else
        redirect_to root_path(client_params), notice: 'Signed in with Github successfully'
      end
    end

    private

    def authorization_url
      client_id = ENV['GITHUB_CLIENT_ID']
      redirect_uri = ENV['GITHUB_REDIRECT_URI']
      scope = 'user:email'
      state = SecureRandom.hex(16)
      session[:state] = state

      "https://github.com/login/oauth/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&state=#{state}"
    end

    def verify_state
      redirect_to new_user_session_path(authorization_params), alert: 'State mismatch error' if params[:state] != session[:state]
    end
  end
end
