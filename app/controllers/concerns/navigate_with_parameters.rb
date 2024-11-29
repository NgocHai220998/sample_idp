# frozen_string_literal: true

module NavigateWithParameters
  extend ActiveSupport::Concern

  included do
    helper_method :authorization_params
  end

  # override helper method of devise
  # https://github.com/plataformatec/devise/blob/v4.7.1/lib/devise/controllers/helpers.rb#L215
  def after_sign_in_path_for(_resource_or_scope)
    if authorization_params[:client_id].present?
      build_authorization_path
    else
      super
    end
  end

  def build_authorization_path
    oauth_authorization_path(authorization_params)
  end

  # authorization_paramsのデフォルト値は空ハッシュ（{}）にします。
  def authorization_params
    if request.env['omniauth.params'].present?
      if request.env['omniauth.params']['authorization_params_query_string'].present?
        query_string_to_permitted_hash(request.env['omniauth.params']['authorization_params_query_string'])
      else
        {}
      end
    elsif request.env['saml_authorization_params'].present?
      query_string_to_permitted_hash(request.env['saml_authorization_params'])
    else
      params.permit(*permitted_param_fields).to_h
    end
  end

  def query_string_to_permitted_hash(query_string)
    URI.decode_www_form(query_string).to_h.with_indifferent_access.slice(*permitted_param_fields)
  end

  def permitted_param_fields
    %i[
      client_id
      redirect_uri
      response_type
      scope
      state
      code_challenge
      code_challenge_method
      nonce
      auth_ui
    ]
  end

  def client_app
    @client_app ||= (OauthApplication.find_by!(uid: authorization_params[:client_id]).as_json if authorization_params[:client_id].present?)
  end

  def oauth_application
    @oauth_application ||= OauthApplication.find_by(uid: authorization_params[:client_id])
  end
end
