# frozen_string_literal: true

WebAuthn.configure do |config|
  config.origin = ENV.fetch('APPLICATION_HOST', 'http://localhost:9999')
  config.rp_name = ENV.fetch('APPLICATION_NAME', 'Sample ID')
  config.credential_options_timeout = 120_000
  config.rp_id = nil
  config.encoding = :base64url
  config.algorithms = %w[ES256 PS256 RS256]
end
