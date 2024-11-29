# frozen_string_literal: true

require 'ostruct'

module Doorkeeper
  module OpenidConnect
    class ClaimsBuilder
      def self.generate(access_token, response)
        resource_owner = Doorkeeper::OpenidConnect.configuration.resource_owner_from_access_token.call(access_token)

        Doorkeeper::OpenidConnect.configuration.claims.to_h.map do |name, claim|
          [name, claim.generator.call(resource_owner)] if access_token.scopes.exists?(claim.scope) && claim.response.include?(response)
        end.compact.to_h
      end
    end
  end
end
