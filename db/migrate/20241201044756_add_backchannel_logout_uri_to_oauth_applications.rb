# frozen_string_literal: true

class AddBackchannelLogoutUriToOauthApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :oauth_applications, :backchannel_logout_uri, :string
  end
end
