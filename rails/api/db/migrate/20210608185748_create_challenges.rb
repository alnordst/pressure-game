class CreateChallenges < ActiveRecord::Migration[6.1]
  def change
    create_table :challenges do |t|
      t.references :player, null: false, foreign_key: true
      t.references :match_configuration, null: false, foreign_key: true

      t.timestamps
    end
  end
end
