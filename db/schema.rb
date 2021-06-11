# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_10_011442) do

  create_table "bots", force: :cascade do |t|
    t.string "discord_id"
    t.string "username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "challenges", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "match_configuration_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_configuration_id"], name: "index_challenges_on_match_configuration_id"
    t.index ["player_id"], name: "index_challenges_on_player_id"
  end

  create_table "concessions", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "match_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_id"], name: "index_concessions_on_match_id"
    t.index ["player_id"], name: "index_concessions_on_player_id"
  end

  create_table "draw_offers", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "match_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_id"], name: "index_draw_offers_on_match_id"
    t.index ["player_id"], name: "index_draw_offers_on_player_id"
  end

  create_table "maps", force: :cascade do |t|
    t.string "name", null: false
    t.integer "creator_id", null: false
    t.integer "ranks"
    t.integer "files"
    t.text "json", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_maps_on_creator_id"
  end

  create_table "match_configurations", force: :cascade do |t|
    t.integer "map_id"
    t.integer "actions_per_turn"
    t.string "turn_progression"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["map_id"], name: "index_match_configurations_on_map_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "red_player_id", null: false
    t.integer "blue_player_id", null: false
    t.integer "match_configuration_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blue_player_id"], name: "index_matches_on_blue_player_id"
    t.index ["match_configuration_id"], name: "index_matches_on_match_configuration_id"
    t.index ["red_player_id"], name: "index_matches_on_red_player_id"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "state_id", null: false
    t.text "json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_moves_on_player_id"
    t.index ["state_id"], name: "index_moves_on_state_id"
  end

  create_table "player_webhooks", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "webhook_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_player_webhooks_on_player_id"
    t.index ["webhook_id"], name: "index_player_webhooks_on_webhook_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "discord_id"
    t.string "username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "states", force: :cascade do |t|
    t.integer "match_id", null: false
    t.text "json"
    t.string "loser"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_id"], name: "index_states_on_match_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "challenges", "match_configurations"
  add_foreign_key "challenges", "players"
  add_foreign_key "concessions", "matches"
  add_foreign_key "concessions", "players"
  add_foreign_key "draw_offers", "matches"
  add_foreign_key "draw_offers", "players"
  add_foreign_key "maps", "players", column: "creator_id"
  add_foreign_key "match_configurations", "maps"
  add_foreign_key "matches", "match_configurations"
  add_foreign_key "matches", "players", column: "blue_player_id"
  add_foreign_key "matches", "players", column: "red_player_id"
  add_foreign_key "moves", "players"
  add_foreign_key "moves", "states"
  add_foreign_key "player_webhooks", "players"
  add_foreign_key "player_webhooks", "webhooks"
  add_foreign_key "states", "matches"
end
