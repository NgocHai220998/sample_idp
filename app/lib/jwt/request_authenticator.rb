# frozen_string_literal: true

module Jwt
  module RequestAuthenticator
    def generate_jwt_token(sub, aud)
      der_binary = Base64.strict_decode64(ENV.fetch('JWT_SIGNING_KEY'))
      rsa = OpenSSL::PKey::RSA.new der_binary
      payload = {
        iss: ENV.fetch('OPENID_CONNECT_ISSUER'),
        aud:,
        exp: 10.minutes.from_now.to_i,
        sub:,
        iat: Time.current.to_i,
        events: {
          'http://schemas.openid.net/event/backchannel-logout': {}
        }
      }

      headers = {
        alg: Doorkeeper::OpenidConnect.signing_algorithm,
        kid: JSON::JWK.new(rsa.public_key)[:kid]
      }

      JWT.encode(payload, rsa, Doorkeeper::OpenidConnect.signing_algorithm.to_s, headers)
    end
  end
end
