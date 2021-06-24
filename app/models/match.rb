require 'httparty'

class Match < ApplicationRecord
  belongs_to :red_player, class_name: "Player"
  belongs_to :blue_player, class_name: "Player"
  belongs_to :match_configuration
  has_many :states, dependent: :destroy
  has_many :draw_offers, dependent: :destroy
  has_many :concessions, dependent: :destroy
  scope :with_player, ->(id) { where('red_player_id = ? or blue_player_id = ?', id, id)}

  before_create do
    match_configuration.map ||= Map.random
  end

  after_create do
    map_data = JSON.parse(match_configuration.map.data, symbolize_names: true)
    board = Board.new map_data
    board.reset
    board.assign_threat
    states.create data: board.to_json
  end

  def expanded
    {
      id: id,
      red_player: red_player,
      blue_player: blue_player,
      match_configuration: match_configuration,
      over: over?,
      winner: winner,
      states: states.map(&:id),
      last_state: states.last
    }
  end

  def players
    [red_player, blue_player].compact
  end

  def webhooks
    players.map(&:webhooks).flatten(1).uniq
  end

  def over?
    states.last.loser ||
    concessions.any? ||
    draw_offers.count >= 2
  end

  def winner
    color = case
    when states.last.loser
      case states.last.loser
      when :red then :blue
      when :blue then :red
      end
    when concessions.any?
      concessions.first.player.id == red_player.id ? :blue : :red
    end
    if color
      {
        color: color,
        player_id: color == :red ? red_player_id : blue_player_id
      }
    end
  end
  def team_of(player)
    case player
    when red_player then :red
    when blue_player then :blue
    end
  end

  def submit_move(player:, commands:)
    board = Board.new(JSON.parse(states.last.data))
    if board.commands_valid? team: team_of(player), commands: commands
      existing_move = states.last.moves.find_by player_id: player.id
      if existing_move
        existing_move.data = commands.to_json
      else
        states.last.create_move player_id: player.id, data: commands.to_json
      end
    end
  end

  def execute_turn
    board = Board.new(JSON.parse(states.last.data))
    moves = states.last.moves.map{ |move| JSON.parse(move.data) }
    board.play moves
    create_state data: board.to_json, loser: board.loser
  end

  def forecast(commands)
    board = Board.new(JSON.parse(states.last.data))
    board.play(commands)
    { data: board.to_json, loser: board.loser }
  end

  def notify(reason)
    webhooks.each do |webhook|
      HTTParty.post(webhook.url, body: {reason: reason, match_id: id})
    end
  end
end
