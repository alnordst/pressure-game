require_relative './terrain'
require_relative './units/artillery'
require_relative './units/command'
require_relative './units/infantry'
require_relative './units/sniper'
require_relative './units/tank'

class Square
  attr_reader :address, :terrain, :threat, :threatened_by, :units

  def initialize(board, address, terrain: {}, unit: nil,
  threat: { red: 0, blue: 0 }, threatened_by: { red: [], blue: [] })
    @board, @address = board, address
    @terrain = Terrain.new(**terrain.slice(:category, :type))

    @units = if unit && unit[:type]
      kwargs = unit.slice(:team, :command)
      the_unit = case unit[:type].to_sym.downcase
      when :artillery then Artillery.new self, **kwargs
      when :command then Command.new self, **kwargs
      when :infantry then Infantry.new self, **kwargs
      when :sniper then Sniper.new self, **kwargs
      when :tank then Tank.new self, **kwargs
      end
      [the_unit]
    else
      []
    end

    @threat, @threatened_by = threat, threatened_by
  end

  def to_h
    {
      address: address.to_sym,
      unit: unit.to_h,
      terrain: terrain.to_h,
      threat: threat,
      threatened_by: threatened_by
    }
  end

  def to_s
    to_h.to_s
  end

  #-- Status --#

  def empty?
    @units.empty?
  end

  def alone?
    @units.length == 1
  end

  def contested?
    @units.map(&:team).uniq.length == 2
  end

  def resolved?
    empty? || alone?
  end

  def unit
    @units.first if alone?
  end

  #-- Actions --#

  def receive_threat(unit)
    @threat[unit.team.to_sym] += unit.offense
    @threatened_by[unit.team.to_sym] << unit.square.address
  end

  def add(unit)
    @units << unit
  end

  def remove(unit)
    @units -= [unit]
  end

  def neighbors(**kwargs, &test)
    @board.neighbors_of(self, **kwargs)
  end

  def reset
    unit&.reset
    @threat = { red: 0, blue: 0}
    @threatened_by = { red: [], blue: [] }
  end
end