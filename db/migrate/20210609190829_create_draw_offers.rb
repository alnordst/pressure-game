class CreateDrawOffers < ActiveRecord::Migration[6.1]
  def change
    create_table :draw_offers do |t|
      t.references :player, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
