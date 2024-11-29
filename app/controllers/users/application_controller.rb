# frozen_string_literal: true

module Users
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user!
  end
end
