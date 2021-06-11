require 'httparty'

class ApplicationController < ActionController::API
  rescue_from ApiError, with: :handle_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate!
    auth = request.headers[:HTTP_AUTHORIZATION]
    response = HTTParty.get('https://discord.com/api/users/@me', {
      headers: { Authorization: auth }
    })
    body = JSON.parse(response.body, symbolize_names: true)
    raise ApiError.new(:forbidden) unless response.code.between?(200, 299)
    if body[:bot]
      bot = Bot.find_by discord_id: body[:id]
      raise ApiError.new(:forbidden) unless bot
      raise ApiError.new(:not_acceptable) unless params[:on_behalf_of][:id]
      do_request_as params[:on_behalf_of]
    else
      do_request_as body
    end
  end

  def do_request_as player_data
    player = Player.find_by discord_id: player_data[:id]
    if player
      player.username = player_data[:username]
      @player = player
    else
      @player = Player.create(
        discord_id: player_data[:id],
        username: player_data[:username]
      )
    end
  end

  def handle_error(error)
    render plain: error.message, status: error.status
  end

  def not_found
    render plain: 'Not found', status: :not_found
  end
end
