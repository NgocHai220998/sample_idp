# frozen_string_literal: true

module Users
  class AdminsController < ApplicationController
    def create
      current_user.update!(admin: true)
      redirect_to oauth_applications_path
    rescue StandardError => e
      flash[:error] = e.message

      redirect_to root_path
    end

    def destroy
      current_user.update!(admin: false)
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to root_path
    end
  end
end
