class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.references :red_player, null: false, foreign_key: false
      t.references :blue_player, null: false, foreign_key: false
      t.references :match_configuration, null: false, foreign_key: true

      t.timestamps
    end
    add_foreign_key :matches, :players, column: :red_player_id
    add_foreign_key :matches, :players, column: :blue_player_id
  end
end
