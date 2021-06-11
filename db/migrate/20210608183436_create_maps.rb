class CreateMaps < ActiveRecord::Migration[6.1]
  def change
    create_table :maps do |t|
      t.string :name, null: false
      t.references :creator, null: false, foreign_key: false
      t.integer :ranks
      t.integer :files
      t.text :data, null: false

      t.timestamps
    end
    # add_index :maps, :name, unique: true
    add_foreign_key :maps, :players, column: :creator_id
  end
end
