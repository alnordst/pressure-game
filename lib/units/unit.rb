require_relative '../team'

class Unit
  attr_accessor :offense_modifier, :defense_modifier, :must_rebound
  attr_reader :square, :team, :threatens, :valid_commands,
    :category, :type, :original_square, :command, :next_command

  def initialize(square, team:, command: nil)
    @square = square
    @original_square = square
    @team = Team.new team
    raise 'invalid team' unless @team
    @command = command
    @valid_commands = []
    @threatens = []
    @base_offense = @base_defense = 1
    @offense_modifier = @defense_modifier = 0
    @category = @type = @next_command = nil
    @moved = @must_rebound = false
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
      base_offense: @base_offense,
      base_defense: @base_defense,
      offense_modifier: offense_modifier,
      defense_modifier: defense_modifier,
      overwhelmed: overwhelmed?,
      moved: moved?
    }
  end

  def to_s
    to_h.to_s
  end

  #-- Statuses --#

  def offense
    @base_offense + offense_modifier + square.terrain.offense_modifier
  end

  def defense
    @base_defense + defense_modifier + square.terrain.defense_modifier
  end

  def overwhelmed?
    defense < square.threat[team.opposite.to_sym]
  end

  def moved?
    @moved
  end

  #-- Actions --#

  def threaten square
    threatens << square.address.to_sym
    square.receive_threat self
  end

  def move_to destination_square
    square.remove self
    @square = destination_square
    square.add self
    @moved = true
  end

  def command= command
    sym = command.upcase.to_sym
    @command = sym if valid_commands.include? sym
  end

  def next_command= command
    @next_command = command if valid_commands.include? command
  end

  #-- Lifecycle --#

  def before_move; end

  def move
    if command
      destination_square = square
        .neighbors(headings: [command])
        .first
      move_to(destination_square) if destination_square.terrain.passable?
      @command = nil
    end
  end

  def after_move; end

  def before_resolve; end

  def rebound
    move_to original_square unless square == original_square
    @must_rebound = false
  end

  def set_next_command
    @command, @next_command = next_command, nil
  end

  def assign_threat; end

  def reset
    @threatens = []
    @offense_modifier = @defense_modifier = 0
  end
end