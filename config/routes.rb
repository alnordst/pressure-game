Rails.application.routes.draw do
  get "/", to: "application#health"

  get "/:resource", to: "records#index"
  get "/:resource/:id", to: "records#show"

  post "/find-game", to: "application#find_game"
  post "/submit-move", to: "application#submit_move"
  post "/concede", to: "application#concede"
  post "/offer-draw", to: "application#offer_draw"
  post "/submit-map", to: "application#submit_map"
  post "/register-webhook", to: "applicatoin#register_webhook"
end
