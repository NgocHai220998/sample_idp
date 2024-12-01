# frozen_string_literal: true

module Users
  class AuthorizationsController < Doorkeeper::AuthorizationsController
    include NavigateWithParameters

    private

    def after_successful_authorization(_context)
      current_resource_owner.authorize!(pre_auth.client.application)

      super
    end
  end
end
