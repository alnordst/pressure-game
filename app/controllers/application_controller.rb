require 'httparty'

class ApplicationController < ActionController::API

  rescue_from ApiError, with: :handle_error

  def health
    render plain: 'Ok', status: :ok
  end

  def find_game
    authenticate!
    # leave off turn progression for now
    # options = params.slice("map_id, :actions_per_turn, :turn_progression")
    options = params.slice("map_id, :actions_per_turn")
    match_configuration = MatchConfiguration.new options

    if @player.challenges.any?{ |c| c.match_configuration.equivalent_to? match_configuration }
      raise ApiError.new(:conflict, "Duplicate challenge")
    end

    challenge = Challenge.find { |c| c.match_configuration.satisfies? match_configuration }
    if challenge
      match_configuration.merge! challenge.match_configuration
      match_configuration.save
      match = match_configuration.create_match(
        red_player_id: challenge.player.id,
        blue_player_id: @player.id
      )
      challenge.destroy
      render json: match, status: :created
    else
      match_configuration.save
      puts 'match config', match_configuration.to_json
      @player.challenges.create(match_configuration_id: match_configuration.id)
      render status: :accepted
    end
  end

  def submit_move
    authenticate!
    match = find_match(params[:match_id])
    if match.submit_move(player: @player, commands: params[:commands])
      render status: :accepted
      if !match.turn_progression && match.states.last.moves.count >= 2
        match.execute_turn
        match.notify(match.over? ? 'match over' : 'next turn')
      end
    else
      raise ApiError.new(:not_acceptable, "Invalid move")
    end
  end

  def concede
    authenticate!
    match = find_match(params[:match_id])
    match.create_concession(player_id: @player.id)
    render status: :accepted
    match.notify('match_over')
  end

  def offer_draw
    authenticate!
    match = find_match(params[:match_id])
    if match.draw_offers.any?{ |offer| offer.player == @player}
      raise ApiError.new(:conflict, "Duplicate draw offer")
    end
    match.create_draw_offer(player_id: @player.id)
    render status: :accepted
    match.notify(match.over? ? 'match over' : 'draw offer')
  end

  def submit_map
    authenticate!
    @player.create_map(name: params[:name], json: params[:json])
    render status: :created
  rescue ActiveRecord::RecordInvalid
    raise ApiError.new(:not_acceptable, "Invalid map")
  end

  def register_webhook
    authenticate!
    webhook = Webhook.find_by(url: params[:url]) ||
      Webhook.create(url: params[:url])
    @player.webhooks << webhook
    render status: :accepted
  end

  def disconnect_webhook
    authenticate!
    webhooks = @player.webhooks.where url: params[:url]
    raise ApiError.new(:not_found) unless webhooks.any?
    webhooks.delete_all
    render status: :ok
  end

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

  def find_match(match_id)
    match = Match.find(match_id)
    if !match.players.include? @player
      raise ApiError.new(:unauthorized, "Not a participant of match")
    elsif match.over?
      raise ApiError.new(:not_acceptable, "Match is over")
    end
  rescue ActiveRecord::RecordNotFound
    raise ApiError.new(:not_found)
  end

  def handle_error(error)
    render plain: error.message, status: error.status
  end
end
