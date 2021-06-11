require_relative './board'
require_relative './database'
require_relative './team'

class Game
  class << self
    def get(**where)
      new(Database.conn[:games_vw].first(where))
    end

    def create(red_player_id:, blue_player_id:, map_id: nil,
    actions_per_turn: nil, turn_progression: nil)
      id = Database.conn[:games].insert(
        red_player_id: red_player_id,
        blue_player_id: blue_player_id,
        map_id: map_id || Database.conn[:maps].order{rand.function}.get(:id),
        actions_per_turn: actions_per_turn
        turn_progression: turn_progression
      )
      @get(id: id)
    end

    # API endpoint
    def post_challenge(player, options)
      existing_challenges = Database.conn[:challenges].where(options)
      if existing_challenges.empty?
        Database.conn[:challenges].insert(player_id: player[:id], **options)
      else
        valid_challenge = existing_challenges
          .exclude(player_id: player[:id])
          .first
        raise 'duplicate challenge' unless valid_challenge
        existing_challenges.where(id: valid_challenge[:id]).delete
        game = Game.create(
          red_player_id: valid_challenge[:player_id],
          blue_player_id: player[:id],
          valid_challenge.slice(:map_id, :actions_per_turn, :turn_progression)
        )
      end
    end
  end

  def initialize(data)
    @data = data.dup
    @board = Board.new(data[:state_data])
    @data[:board] = @board
  end

  def to_h
    @data
  end

  def game_over?
    @data[:is_complete]
  end

  def participant?(player)
    @data.values_at(:red_player_id, :blue_player_id).include? player[:id]
  end

  def both_moves_submitted?
    @state.values_at(:red_player_move_data, :blue_player_move_data).all?
  end

  def team_of(player)
    if @data[:red_player_id] == player[:id]
      Team.new(:red)
    elsif @data[:blue_player_id] == player[:id]
      Team.new(:blue)
    end
  end

  def state
    Database.conn[:states_vw].first(id: @data[:last_state_id])
  end

  def execute_turn
    @board.load_commands @state.values_at(
      :red_player_move_data,
      :blue_player_move_data
    ).flatten(1)
    @board.move
    @board.resolve
    Database.conn[:states].insert(
      game_id: @data[:id],
      state_data: @board.to_h(slim?: true)
    )
    if @board.game_over?
      Database.conn[:games].where(id: @data[:id]).update(
        is_complete: true,
        winner: @board.winner
      )
    end
    @get(id: @data[:id])
  end

  # API endpoint
  def submit_move(player, commands)
    raise 'game is over' if @game_over?
    raise 'player not in game' unless @participant?(player)
    raise 'too many actions' if commands.size > @data[:actions_per_turn]
    raise 'invalid commands' unless @board.valid_commands?(
      team: team_of player,
      commands: commands
    )
    existing_move = Database.conn[:moves].where(
      state_id: @data[:last_state_id],
      player_id: player[:id]
    )
    if existing_move.empty?
      Database.conn[:moves].insert(
        state_id: @data[:last_state_id],
        player_id: player[:id],
        move_data: commands
      )
    else
      existing_move.update(move_data: commands)
    end
    if @data[:turn_progression].nil? && @both_moves_submitted?
      @execute_turn
  end

  # API endpoint
  def concede(player)
    raise 'game is over' if @game_over?
    raise 'player not in game' unless @participant? player
    Database.conn[:games].where(id: @data[:id]).update(
      is_complete: true,
      winner: @team_of(player).opposite
    )
  end

  # API endpoint
  def offer_draw(player)
    raise 'game is over' if @game_over?
    raise 'player not in game' unless @participant? player
    Database.conn[:games].where(id: @data[:id]).update(
      "#{team_of(player)}_offered_draw".to_sym => true
    )
    both_offered? = Database.conn[:games]
      .where(id: @data[:id])
      .get([:red_offered_draw, :blue_offered_draw])
      .all?
    if both_offered?
      Database.conn[:games].where(id: @data[:id]).update(
        is_complete: true
      )
  end
end