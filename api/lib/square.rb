require_relative './terrain.rb'
require_relative './unit.rb'

class Square
  attr_reader :terrain, :address, :threat, :threatened_by

  def initialize(board, address, terrain:, unit: nil)
    @board, @address = board, address
    @terrain = Terrain.create(**terrain)
    @units = unit ? [Unit.new(self, **unit)] : []
    @threat = { red: 0, blue: 0 }
    @threatened_by = { red: [], blue: [] }
  end

  def to_h(slim?: false)
    def h = {
      terrain: terrain.to_h(slim?: slim),
      unit: unit.to_h(slim?: slim)
    }
    h.merge!(
      address: address,
      threat: threat,
      threatened_by: threatened_by
    ) unless slim
    return h
  end

  #-- Status --#

  def defense_modifier
    terrain.defense_modifier
  end

  def passable?
    terrain.passable?
  end

  def obstructed?
    terrain.obstructed? || !empty?
  end

  def empty?
    units.empty?
  end

  def alone?
    units.length == 1
  end

  def contested?
    units.map(&:team).uniq.length == 2
  end

  def resolved?
    empty? || alone?
  end

  def unit
    units.first if alone?
  end

  #-- Actions --#

  def receive_threat(unit)
    threat[unit.team] += unit.attack
    threatened_by[unit.team] << unit.square.address
  end

  def add(unit)
    units << unit
  end

  def remove(unit)
    units -= unit
  end

  def command=(new_command)
    unit&.command = new_command
  end

  def neighbors(**kwargs)
    board.neighbors_of(self, **kwargs)
  end

  #-- Lifecycle --#

  def assign_threat
    unit&.assign_threat
  end

  def before_move
    unit&.before_move
  end

  def move
    unit&.move
  end

  def after_move
    units.each { |unit| unit.after_move }
  end

  def resolve
    units.reject!(&:overwhelmed?) if contested?
    units.dup.each(&:rebound) unless resolved?
  end
end