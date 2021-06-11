require 'sinatra'
require 'sinatra/cors'
require 'sinatra/json'
require 'sinatra/required_params'
require_relative './game'
require_relative './system'

set :allow_origin, "*"
set :allow_methods, "GET,POST"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

use Rack::JSONBodyParser

get '/' do
  200
end

['player', 'game', 'map'].each do |table|
  get '/#{table}s' do
    Database.get('#{table}_vw', params)
  end

  get '/#{table}' do
    Database.get_one('#{table}_vw', params) || 404
  end
end

before do
  if request.post?
    @player = if params[:token] == env['BOT_TOKEN']
      params[:player]
    else
      System.authorize params[:token]
    end
    halt 401 unless @player
  end
end

post '/find-game' do
  options = params.slice(:map_id, :pw, :turn_progression)
  game = Game.post_challenge(player, options)
  game || 204
end

post '/submit-move' do
  required_params :game_id, :commands
  game = Game.get(game_id: params[:game_id])
  new_state = game.submit_move(player, params[:commands])
  new_state || 204
end

post '/concede' do
  required_params :game_id
  game = Game.get(game_id: params[:game_id])
  game.concede(player)
  200
end

post '/offer-draw' do
  required_params :game_id
  game = Game.get(game_id: params[:game_id])
  game.offer_draw(player) ? 200 : 204
end

post '/submit-map' do
  required_params :map
  System.submit_map(player, params[:map])
  200
end

post '/register-webhook' do
  required_params :url
  System.register_webhook(player, params[:url])
  200
end
