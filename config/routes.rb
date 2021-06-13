Rails.application.routes.draw do
  root to: "docs#index"

  get "/map", to: "map#all"
  get "/map/:id", to: "map#by_id"

  get "/match", to: "match#all"
  get "/match/:id", to: "match#by_id"

  get "/player/:id", to: "player#by_id"
  get "/player/from-discord-id/:discord_id", to: "player#by_discord_id"
  get "/player/:id/matches", to: "player#matches"
  get "/player/:id/maps", to: "player#maps"

  post "/map/submit-map", to: "map#submit_map"

  post "/match/find-match", to: "match#find_match"
  post "/match/:id/submit-move", to: "match#submit_move"
  post "/match/:id/forecast", to: "match#forecast"
  post "/match/:id/concede", to: "match#concede"
  post "/match/:id/offer-draw", to: "match#offer_draw"

  post "/player/list-webhooks", to: "player#list_webhooks"
  post "/player/register-webhook", to: "player#register_webhook"
  post "/player/disconnect-webhook", to: "player#disconnect_webhook"

  get "/state/:id", to: "state#by_id"
end
