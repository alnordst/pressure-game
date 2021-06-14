require_relative './address'
require_relative './square'

class Board
  attr_reader :ranks, :files

  def initialize(data)
    @ranks = data.size
    @files = data.first.size
    @data_h = {}
    @data_m = data.map.with_index do |row, row_index|
      row.map.with_index do |square, col_index|
        address = Address.new(ranks - row_index, col_index + 1)
        kwargs = square.slice(:terrain, :unit, :threat, :threatened_by)
        square_obj = Square.new(self, address, **kwargs)
        @data_h[address.to_sym.downcase] = square_obj
        square_obj
      end
    end
  end

  def serialized
    @data_m.map do |row|
      row.map do |square|
        square.to_h
      end
    end
  end

  def to_s
    serialized.to_s
  end

  def to_json
    JSON.generate(serialized)
  end

  def [](address)
    @data_h[address.to_sym.downcase]
  end

  alias square_at []

  def squares
    @data_h.values
  end

  def loser
    red_lost = squares.map(&:unit).compact
      .none?{ |unit| unit.team == :red && unit.type == :command }
    blue_lost = squares.map(&:unit).compact
      .none?{ |unit| unit.team == :blue && unit.type == :command }
    case
    when red_lost && blue_lost then :both
    when red_lost then :red
    when blue_lost then :blue
    else nil
    end
  end

  def neighbors_of(square, headings:, iterations: 1, units: false,
  rotate: false, inclusive: false, &test)
    h = rotate ? Address.rotate(headings) : headings
    squares = h.each.with_object([]) do |heading, squares|
      iterations.times do |distance|
        address = square.address.go_in heading, distance
        destination = square_at address
        break unless destination
        passed = test ? test.(destination) : true
        squares << destination if passed || inclusive
        break unless passed
      end
    end
    units ? squares.map(&:unit).compact : squares
  end

  def commands_valid?(team:, commands:)
    no_dup_addresses = commands.size == commands
      .map{ |command| command[:address].to_sym.downcase }
      .uniq
      .size
    otherwise_valid = commands.all? do |command|
      square = square_at command[:address]
      square.unit &&
      square.unit.team == team.to_sym &&
      square.unit.valid_commands.include?(command[:value])
    end
    no_dup_addresses && otherwise_valid
  end

  def play(commands)
    commands.each do |command|
      square_at(command[:address]).unit&.command = command[:value]
    end
    @move
    @resolve
    @set_next_command
    @assign_threat
  end

  def move
    squares.each{ |square| square.unit&.before_move }
    squares.each{ |square| square.unit&.move }
    squares.each{ |square| square.units.each(&:after_move) }
  end

  def resolve
    until squares.all?(&:resolved?) do
      assign_threat
      unresolved_squares = squares.reject(&:resolved?)
      unresolved_squares.each{ |square| square.units.each(&:before_resolve) }
      unresolved_squares.each do |square|
        square.units.reject!(&:overwhelmed?) if square.contested?
        unless square.resolved?
          square.units.each{ |unit| unit.must_rebound = true }
        end
      end
      unresolved_squares.each do |square|
        square.units.select(&:must_rebound).each(&:rebound)
      end
    end
  end

  def set_next_command
    squares.each{ |square| square.unit&.set_next_command }
  end

  def assign_threat
    reset
    squares.each{ |square| square.unit&.assign_threat }
  end

  def reset
    squares.each(&:reset)
  end
end