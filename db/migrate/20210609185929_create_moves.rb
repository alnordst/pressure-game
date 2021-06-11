class CreateMoves < ActiveRecord::Migration[6.1]
  def change
    create_table :moves do |t|
      t.references :player, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.text :data

      t.timestamps
    end
  end
end
