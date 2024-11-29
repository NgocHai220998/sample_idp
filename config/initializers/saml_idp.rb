# frozen_string_literal: true

SamlIdp.configure do |config|
  config.x509_certificate = ENV.fetch('SAML_CERTIFICATE', '') # Some kind of certificate can public to verify the signature on the SAML response
  config.secret_key = ENV.fetch('SAML_SECRET_KEY', '') # A secret key used to sign the SAML response
  config.algorithm = :sha256 # The algorithm to use when signing the SAML response
  config.base_saml_location = "#{ENV.fetch('APPLICATION_HOST', 'http://localhost:9999')}/saml" # The base URL to use when generating SAML URLs
  config.entity_id = config.base_saml_location # The entity ID for the SAML response, just base SAML location for now
  config.single_service_post_location = "#{config.base_saml_location}/auth" # The URL to POST the SAML response to
  config.single_service_redirect_location = "#{config.base_saml_location}/auth"
  config.single_logout_service_post_location = "#{config.base_saml_location}/logout"
  config.single_logout_service_redirect_location = "#{config.base_saml_location}/logout"

  # config.password = "secret_key_password"
  # config.organization_name = "Your Organization"
  # config.organization_url = "http://example.com"
  # config.reference_id_generator                                 # Default: -> { SecureRandom.uuid }
  # config.attribute_service_location = "#{base}/saml/attributes"
  # config.session_expiry = 86400                                 # Default: 0 which means never
  # config.signed_assertion = true, not supported
  # config.compress = true                                        # Default: false which means the SAML Response is not being compressed
  # config.logger = ::Logger.new($stdout)                         # Default: if in Rails context - Rails.logger, else ->(msg) { puts msg }.

  # Principal (e.g. User) is passed in when you `encode_response`
  #
  # config.name_id.formats =
  #   {                         # All 2.0
  #     email_address: -> (principal) { principal.email_address },
  #     transient: -> (principal) { principal.id },
  #     persistent: -> (p) { p.id },
  #   }
  #   OR
  #
  #   {
  #     "1.1" => {
  #       email_address: -> (principal) { principal.email_address },
  #     },
  #     "2.0" => {
  #       transient: -> (principal) { principal.email_address },
  #       persistent: -> (p) { p.id },
  #     },
  #   }
  config.name_id.formats = {
    email_address: ->(principal) { principal.email },   # Use the email attribute
    transient: ->(principal) { principal.id.to_s },     # Use the user ID for transient (must be string)
    persistent: ->(principal) { principal.uuid || principal.id.to_s } # Use a UUID or ID for persistent
  }

  # If Principal responds to a method called `asserted_attributes`
  # the return value of that method will be used in lieu of the
  # attributes defined here in the global space. This allows for
  # per-user attribute definitions.
  #
  ## EXAMPLE **
  # class User
  #   def asserted_attributes
  #     {
  #       phone: { getter: :phone },
  #       email: {
  #         getter: :email,
  #         name_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS,
  #         name_id_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS
  #       }
  #     }
  #   end
  # end
  #
  # If you have a method called `asserted_attributes` in your Principal class,
  # there is no need to define it here in the config.

  # config.attributes # =>
  #   {
  #     <friendly_name> => {                                                  # required (ex "eduPersonAffiliation")
  #       "name" => <attrname>                                                # required (ex "urn:oid:1.3.6.1.4.1.5923.1.1.1.1")
  #       "name_format" => "urn:oasis:names:tc:SAML:2.0:attrname-format:uri", # not required
  #       "getter" => ->(principal) {                                         # not required
  #         principal.get_eduPersonAffiliation                                # If no "getter" defined, will try
  #       }                                                                   # `principal.eduPersonAffiliation`, or no values will
  #    }                                                                      # be output
  #
  ## EXAMPLE ##
  # config.attributes = {
  #   GivenName: {
  #     getter: :first_name,
  #   },
  #   SurName: {
  #     getter: :last_name,
  #   },
  # }
  ## EXAMPLE ##

  # config.technical_contact.company = "Example"
  # config.technical_contact.given_name = "Jonny"
  # config.technical_contact.sur_name = "Support"
  # config.technical_contact.telephone = "55555555555"
  # config.technical_contact.email_address = "example@example.com"

  # `identifier` is the entity_id or issuer of the Service Provider,
  # settings is an IncomingMetadata object which has a to_h method that needs to be persisted
  config.service_provider.metadata_persister = lambda { |identifier, settings|
    fname = identifier.to_s.gsub(%r{/|:}, '_')
    FileUtils.mkdir_p(Rails.root.join('cache/saml/metadata').to_s)
    File.open Rails.root.join("cache/saml/metadata/#{fname}"), 'r+b' do |f|
      Marshal.dump settings.to_h, f
    end
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # `service_provider` is a ServiceProvider object. Based on the `identifier` or the
  # `service_provider` you should return the settings.to_h from above
  config.service_provider.persisted_metadata_getter = lambda { |identifier, _service_provider|
    fname = identifier.to_s.gsub(%r{/|:}, '_')
    FileUtils.mkdir_p(Rails.root.join('cache/saml/metadata').to_s)
    full_filename = Rails.root.join("cache/saml/metadata/#{fname}")
    if File.file?(full_filename)
      File.open full_filename, 'rb' do |f|
        Marshal.load f # rubocop:disable Security/MarshalLoad
      end
    end
  }

  config.service_provider.finder = lambda do |issuer_or_entity_id|
    service_providers = ServiceProvider.all.index_by(&:metadata_url)
    sp = service_providers[issuer_or_entity_id]

    {
      metadata_url: sp.metadata_url,
      response_hosts: sp.response_hosts.split(' ')
      # fingerprint: 'fingerprint' The fingerprint of the certificate used by the SP use to verify the signature on the SAML Request
      # But sign to SAML Request is making a of lot cost, so that not common way in the world!
    }
  end
end
