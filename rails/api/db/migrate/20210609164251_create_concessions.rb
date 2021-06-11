class CreateConcessions < ActiveRecord::Migration[6.1]
  def change
    create_table :concessions do |t|
      t.references :player, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
