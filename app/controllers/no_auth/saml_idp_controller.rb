# frozen_string_literal: true

module NoAuth
  class SamlIdpController < ApplicationController
    include SamlIdp::Controller

    protect_from_forgery

    before_action :validate_saml_request, only: %i[new create logout]

    def new
      render template: 'saml_idp/idp/new'
    end

    def show
      render xml: SamlIdp.metadata.signed
    end

    def create
      unless params[:email].blank? && params[:password].blank?
        person = idp_authenticate(params[:email], params[:password])
        if person.nil?
          @saml_idp_fail_msg = 'Incorrect email or password.'
        else
          @saml_response = idp_make_saml_response person
          render template: 'saml_idp/idp/saml_post', layout: false # If you read SAML spec you'll see the response in this endpoint
                                                                   # must be the form data and auto-submitted to the SP endpoint # rubocop:disable Layout/CommentIndentation
          return
        end
      end

      render template: 'saml_idp/idp/new'
    end

    def logout
      idp_logout
      @saml_response = idp_make_saml_response(nil)
      render template: 'saml_idp/idp/saml_post', layout: false
    end

    def idp_logout
      user = User.by_email(saml_request.name_id)
      user.logout
    end
    private :idp_logout

    def idp_authenticate(email, password)
      user = User.find_for_authentication(email:)

      return nil unless user&.valid_password?(password)

      user
    end
    protected :idp_authenticate

    def idp_make_saml_response(person)
      encode_response person, signed_message: true do |response|
        response.name_id = person.email # or person.id or another unique identifier
        response.name_id_format = Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS # Update format as necessary

        # Optional: Add attributes to the SAML assertion
        response.attributes[:email] = person.email

        # NOTE: encryption is optional, use it if required
        response.encryption = {
          cert: saml_request.service_provider.cert,
          block_encryption: 'aes256-cbc',
          key_transport: 'rsa-oaep-mgf1p'
        }
      end
    end
    protected :idp_make_saml_response
  end
end
