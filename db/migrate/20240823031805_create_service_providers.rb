# frozen_string_literal: true

class CreateServiceProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :service_providers do |t|
      t.string :name
      t.string :metadata_url
      t.text :response_hosts
      t.string :fingerprint

      t.timestamps
    end
  end
end
