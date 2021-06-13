require_relative '../team'

class Unit
  attr_accessor :offense_modifier, :defense_modifier
  attr_reader :square, :team, :threatens, :valid_commands,
    :category, :type, :previous_square, :command, :next_command,
    :base_offense, :base_defense

  def initialize(square, team:, command: nil, threatens: [],
  defense_modifier: 0, offense_modifier: 0)
    @square = square
    @category, @type, @next_command = nil
    @valid_commands = []
    @base_offense = 1
    @base_defense = 1
    @team = Team.new team
    raise 'invalid team' unless @team
    @command, @threatens = command, threatens
    @offense_modifier, @defense_modifier = offense_modifier, defense_modifier
  end

  def to_h
    {
      team: team.to_sym,
      category: category,
      type: type,
      command: command,
      threatens: threatens,
      valid_commands: valid_commands,
      offense: offense,
      defense: defense,
      base_offense: base_offense,
      base_defense: base_defense,
      offense_modifier: offense_modifier,
      defense_modifier: defense_modifier,
      overwhelmed: overwhelmed?
    }
  end

  def to_s
    to_h.to_s
  end

  #-- Statuses --#

  def offense
    base_offense + offense_modifier + square.offense_modifier
  end

  def defense
    base_defense + defense_modifier + square.defense_modifier
  end

  def overwhelmed?
    defense < square.threat[team.opposite.to_sym]
  end

  def moved?
    square != previous_square && !previous_square.nil?
  end

  #-- Actions --#

  def threaten square
    threatens << square.address
    square.receive_threat self
  end

  def move_to destination_square
    previous_square, square = square, destination_square
    previous_square.remove self
    square.add self
  end

  def command= command
    @command = command if valid_commands.include? command
  end

  def next_command= command
    next_command = command if valid_commands.include? command
  end

  #-- Lifecycle --#

  def before_move; end

  def move
    if command
      destination_square = square
        .neighbors(headings: [command])
        .first
      move_to(destination_square) if destination_square.passable?
    end
  end

  def after_move; end

  def before_resolve; end

  def rebound
    square.remove self
    previous_square.add self
    square, previous_square = previous_square, nil
  end

  def set_next_command
    command, next_command = next_command, nil
  end

  def assign_threat; end

  def reset
    previous_square = nil
    threatens = []
    offense_modifier, defense_modifier = 0
  end
end