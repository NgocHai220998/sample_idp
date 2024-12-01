# frozen_string_literal: true

module WellKnown
  class DoorkeeperDiscoveryController < Doorkeeper::OpenidConnect::DiscoveryController
    private

    def keys_response
      der_binary = Base64.strict_decode64(ENV.fetch('JWT_SIGNING_KEY'))
      rsa = OpenSSL::PKey::RSA.new der_binary
      keys = super
      keys[:keys] << JSON::JWK.new(
        rsa.public_key,
        use: :sign,
        alg: Doorkeeper::OpenidConnect.signing_algorithm
      )

      keys
    end
  end
end
