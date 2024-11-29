# frozen_string_literal: true

class CreateWebauthnIds < ActiveRecord::Migration[6.0]
  def change
    create_table :webauthn_ids do |t|
      t.bigint :user_id, null: false
      t.string :webauthn_id, null: false

      t.timestamps
    end

    add_index :webauthn_ids, :user_id, unique: true
    add_index :webauthn_ids, :webauthn_id, unique: true
  end
end
