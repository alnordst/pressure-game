class CreatePlayerWebhooks < ActiveRecord::Migration[6.1]
  def change
    create_table :player_webhooks do |t|
      t.references :player, null: false, foreign_key: true
      t.references :webhook, null: false, foreign_key: true

      t.timestamps
    end
  end
end
