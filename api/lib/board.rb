require_relative './address.rb'
require_relative './square.rb'

class Board
  attr_reader :ranks, :files

  def initialize(data)
    @ranks = data.size
    @files = data.first.size
    @data_h = {}
    @data_m = data.map.with_index do |row, row_index|
      row.map.with_index do |square, col_index|
        address = Address.new(ranks - row_index, col_index + 1)
        square_obj = Square.new(self, address, **square)
        @data_h[address.to_sym] = square_obj
        square_obj
      end
    end
    @assign_threat
  end

  def to_h(slim: false)
    data_m.map do |row|
      row.map { |square| square.to_h(slim?: slim)}
    end
  end

  def [](address)
    data_h[address.to_sym]
  end

  alias square_at []

  def squares
    data_h.values
  end

  def neighbors_of(square, headings:, iterations: 1, test: proc { true },
  units?: false, rotate?: false, inclusive?: false )
    h = rotate? ? Address.rotate headings : headings
    squares = h.each.with_object([]) do |heading, squares|
      iterations.times do |distance|
        address = square.address.go_in heading, distance
        destination = square_at address
        break unless destination
        passed? = test.(destination)
        squares << destination if passed? || inclusive?
        break unless passed?
      end
    end
    units? ? squares.map(&:unit).compact : squares
  end

  def valid_commands?(team:, commands:)
    directions = [:NW, :N, :NE, :E, :SE, :S, :SW, :W, :C]
    commands.all? do |command|
      @square_at(command[:address]).unit&.team == team &&
      directions.include? command[:direction]
  end

  def game_over?
    [:red, :blue].any? do |team|
      @squares.none? do |square|
        square.unit&.team == team && square.unit&.type == :command
      end
    end
  end

  def winner
    red_lost? = @square.none? do |square|
      square.unit&.team == :red && square.unit&.type == :command
    end
    blue_lost? = @square.none? do |square|
      square.unit&.team == :blue && square.unit&.type == :command
    end
    case
    when red_lost? && blue_lost? then nil
    when red_lost? then :blue
    when blue_lost? then :red
    else nil
    end
  end

  def assign_threat
    squares.each(&:assign_threat)
  end

  def load_commands(commands)
    commands.each do |command|
      @square_at(command[:address]).command = command[:direction]
  end

  def move
    squares.each(&:before_move)
    squares.each(&:move)
    squares.each(&:after_move)
  end

  def resolve
    until squares.all?(&:resolved?) do
      squares.each(&:resolve)
    end
  end

  def cleanup
    square.each(&:cleanup)
  end
end