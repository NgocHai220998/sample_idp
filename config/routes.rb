# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'top#index'
  use_doorkeeper_openid_connect
  use_doorkeeper do
    controllers applications: 'admins/oauth_applications'
  end
  resources :service_providers, controller: 'admins/service_providers' # TODO: Need to refactor this later
  devise_for :users, controllers: { sessions: 'no_auth/sessions', registrations: 'no_auth/registrations' }

  devise_scope :user do
    scope module: :users do
      resources :webauthn_credentials, path: 'webauthn/credentials', only: %i[index create destroy], as: :user_webauthn_credentials do
        collection do
          post :options
        end
      end

      resource :webauthn_auto_upgrade, path: 'webauthn/auto_upgrade', only: :show do
        collection do
          get :finalize
        end
      end

      # TODO: Need to refactor this later
      resources :admins, only: %i[create destroy]
    end
  end

  scope module: :no_auth do
    # WebAuthn routes
    resource :webauthn_assertion, path: 'webauthn/assertion', only: :create do
      collection do
        post :options
      end
    end

    # SAML IdP routes, TODO: Need to refactor this later
    get '/saml/metadata' => 'saml_idp#show' # Expose the SAML metadata of the IdP
    get '/saml/auth' => 'saml_idp#new' # The screen to authenticate the user
    post '/saml/auth' => 'saml_idp#create' # The SAML IdP authentication endpoint
    match '/saml/logout' => 'saml_idp#logout', via: %i[get post delete] # The SAML IdP logout endpoint

    # Github OAuth routes, TODO: Need to refactor this later
    get '/auth/github/callback', to: 'omniauth_callbacks#callback'
    get '/auth/github', to: 'omniauth_callbacks#new'
  end
end
