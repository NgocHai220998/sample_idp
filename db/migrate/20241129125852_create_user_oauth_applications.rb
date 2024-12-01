# frozen_string_literal: true

class CreateUserOauthApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :user_oauth_applications do |t|
      t.references :user, null: false
      t.references :oauth_application, null: false
      t.timestamps
    end

    add_index :user_oauth_applications, %i[user_id oauth_application_id], unique: true
  end
end
