require_relative './team.rb'
require_relative './units/artillery.rb'
require_relative './units/command.rb'
require_relative './units/infantry.rb'
require_relative './units/sniper.rb'
require_relative './units/tank.rb'

class Unit
  attr_accessor :offense_modifier, :defense_modifier
  attr_reader :square, :team,
    :threatens, :valid_commands,
    :category, :type, :previous_square, :command, :next_command

  def initialize square, team
    @square, @team = square, team
    @base_offense, @base_defense = 1
    @offense_modifier, @defense_modifier = 0
    @threatens, @valid_commands = []
    @category, @type, @previous_square, @command, @next_command
  end

  def self.create(square, team:, type:)
    case type
    when :artillery then Artillery.new square, Team.new(team)
    when :command then Command.new square, Team.new(team)
    when :infantry then Infantry.new square, Team.new(team)
    when :sniper then Sniper.new square, Team.new(team)
    when :tank then Tank.new square, Team.new(team)
    end
  end

  def to_h(slim?: false)
    essential = {
      category: @category,
      type: @type,
      team: @team,
      next_command: @next_command
    }
    extra = {
      previous_square: @previous_square
      command: @command
      threatens: @threatens
      valid_commands: @valid_commands
      offense: @offense
      defense: @defense
      overwhelmed: @overwhelmed?
      moved: @moved
    }
    slim? ? essential : essential.merge extra
  end

  ## Statuses ##
  def offense
    @base_offense + @offense_modifier
  end

  def defense
    @base_defense + @defense_modifier + @square.defense_modifier
  end

  def overwhelmed?
    @defense < @square.threat[@team.opposite]
  end

  def moved?
    @square != @previous_square && !@previous_square.nil?
  end

  ## Actions ##
  def threaten square
    @threatens << square.address
    square.receive_threat self
  end

  def move_to square
    @previous_square, @square = @square, square
    @previous_square.remove self
    @square.add self
  end

  def command= command
    @command = command if @valid_commands.includes? command
  end

  def next_command= command
    @next_command = command if @valid_commands.includes? command
  end

  ## Lifecycle ##
  def assign_threat; end

  def before_move; end

  def move
    if @command
      square = @square
        .neighbors(headings: [@command])
        .first
      @move_to square if square.passable?
    end
  end

  def after_move; end

  def rebound
    @square.remove self
    @previous_square.add self
    @square, @previous_square = @previous_square, nil
  end
end