class CreateBots < ActiveRecord::Migration[6.1]
  def change
    create_table :bots do |t|
      t.string :discord_id
      t.string :username

      t.timestamps
    end
  end
end
