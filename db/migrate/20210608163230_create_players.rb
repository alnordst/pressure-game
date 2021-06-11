class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :discord_id
      t.string :username

      t.timestamps
    end
  end
end
