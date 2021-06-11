class CreateMatchConfigurations < ActiveRecord::Migration[6.1]
  def change
    create_table :match_configurations do |t|
      t.references :map, foreign_key: true
      t.integer :actions_per_turn
      t.string :turn_progression

      t.timestamps
    end
  end
end
