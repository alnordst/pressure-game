class MatchController < ApplicationController
  def all
    render json: Match.all, status: :ok
  end

  def by_id
    render json: Match.find(params[:id]).expanded, status: :ok
  end

  def find_match
    authenticate!
    match_configuration = MatchConfiguration.new params[:match_configuration]

    if @player.challenges.any? do |c|
      c.match_configuration.equivalent_to? match_configuration &&
      c.password == params[:password]
    end
      raise ApiError.new(:conflict, "Duplicate challenge")
    end

    challenge = Challenge.find do |c|
      c.match_configuration.satisfies? match_configuration &&
      c.password == params[:password]
    end
    if challenge
      match_configuration.merge! challenge.match_configuration
      match_configuration.save
      match = match_configuration.create_match(
        red_player_id: challenge.player.id,
        blue_player_id: @player.id
      )
      challenge.destroy
      render json: match.expanded, status: :created
    else
      match_configuration.save
      puts 'match config', match_configuration.to_json
      @player.challenges.create(match_configuration_id: match_configuration.id)
      render status: :accepted
    end
  end

  def submit_move
    authenticate!
    match = get_match(params[:id])
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

  def forecast
    authenticate!
    match = get_match(params[:id])
    state = match.forecast(params[:commands])
    render json: state, status: :ok
  end

  def concede
    authenticate!
    match = get_match(params[:id])
    match.create_concession(player_id: @player.id)
    render status: :accepted
    match.notify('match_over')
  end

  def offer_draw
    authenticate!
    match = get_match(params[:id])
    if match.draw_offers.any?{ |offer| offer.player == @player}
      raise ApiError.new(:conflict, "Duplicate draw offer")
    end
    match.create_draw_offer(player_id: @player.id)
    render status: :accepted
    match.notify(match.over? ? 'match over' : 'draw offer')
  end

  private

  def get_match(id)
    match = Match.find(id)
    if !match.players.include? @player
      raise ApiError.new(:unauthorized, "Not a participant of match")
    elsif match.over?
      raise ApiError.new(:not_acceptable, "Match is over")
    end
  rescue ActiveRecord::RecordNotFound
    raise ApiError.new(:not_found)
  end
end
