# frozen_string_literal: true

module Admins
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user! # TODO: Need to refactor later
  end
end
