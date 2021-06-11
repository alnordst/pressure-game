require_relative './unit'

class Vehicle < Unit
  def initialize square, **kwargs
    super
    @category = :vehicle
    @valid_commands = [:N, :E, :S, :W, :C]
  end

  # vehicles continue rolling unless move failed or moved to obstructed terrain
  def move
    super
    next_command = command if moved? && !square.terrain.obstructed?
  end
end