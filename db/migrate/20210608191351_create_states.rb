class CreateStates < ActiveRecord::Migration[6.1]
  def change
    create_table :states do |t|
      t.references :match, null: false, foreign_key: true
      t.text :data
      t.string :loser

      t.timestamps
    end
  end
end
