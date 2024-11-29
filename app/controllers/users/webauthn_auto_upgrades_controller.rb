# frozen_string_literal: true

module Users
  class WebauthnAutoUpgradesController < ApplicationController
    def show
      session[:auto_upgrade] = true
    end

    def finalize
      redirect_to after_sign_in_path_for(current_user), allow_other_host: true
    end
  end
end
