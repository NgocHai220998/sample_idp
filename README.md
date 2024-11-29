# Sample Identity Provider (IdP) Project

This project is a Ruby on Rails-based Identity Provider (IdP) serving as an ID management system, supporting OAuth 2.0, OpenID Connect, and SAML protocols.

*Note that*: this project serves as a place for me to document what I’ve learned during my work. If you notice any mistakes, please let me know so I can improve.

### Features
- User authentication and authorization.
  - Password traditional
  - Github
  - Passkeys
- Support for [OAuth 2.0](https://datatracker.ietf.org/doc/html/rfc6749) and [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) specification as much as possible to build an identity and authentication infrastructure.

### How to run the project?

To run the project locally, follow these steps:

```
source .envrc OR direnv allow  

bundle install
rails db:create db:migrate
rails webpacker:compile
rails s
```

Alternatively, you can run the project using Docker:

```
docker compose up
```
