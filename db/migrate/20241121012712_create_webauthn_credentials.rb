# frozen_string_literal: true

class CreateWebauthnCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :webauthn_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.string :registered_os, null: false, default: 'unknown'
      t.string :registered_browser, null: false, default: 'unknown'
      t.datetime :last_used_at
      t.bigint :sign_count, null: false, default: 0

      t.timestamps
    end

    add_index :webauthn_credentials, :external_id, unique: true
  end
end
