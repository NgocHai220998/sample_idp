# frozen_string_literal: true

module Jwt
  module RequestAuthenticator
    def generate_jwt_token(url)
      der_binary = Base64.strict_decode64(ENV.fetch('JWT_SIGNING_KEY'))
      rsa = OpenSSL::PKey::RSA.new der_binary
      payload = {
        iss: ENV.fetch('OPENID_CONNECT_ISSUER'),
        aud: url,
        exp: 30.minutes.from_now.to_i,
        sub: ENV.fetch('OPENID_CONNECT_ISSUER'),
        iat: Time.current.to_i
      }

      headers = {
        alg: 'RS256',
        kid: JSON::JWK.new(rsa.public_key)[:kid]
      }

      JWT.encode(payload, rsa, Doorkeeper::OpenidConnect.signing_algorithm.to_s, headers)
    end
  end
end
