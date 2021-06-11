require_relative './unit'

class Infantry < Unit
  def initialize square, **kwargs
    super
    @category, @type = :infantry
    @valid_commands = [:NW, :N, :NE, :E, :SE, :S, :SW, :W, :C]
  end

  def assign_threat
    super
    @square
      .neighbors(headings:[[0, 1], [1, 1]], rotate: true)
      .each { |square| threaten square }
  end

  def afterMove
    super
    follower_directions = {
      N: [:SE, :S, :SW],
      E: [:SW, :W, :NW],
      S: [:NW, :N, :NE],
      W: [:NE, :E, :SE]
    }
    if follower_directions.has_key? @command
      @previous_square
        .neighbors(headings: follower_directions[@command], units: true)
        .filter { |unit| unit.category == :infantry && unit.team == @team }
        .each do |unit|
          unless unit.next_command
            unit.next_command = @command
          else
            directions = [:NW, :N, :NE, :E, :SE, :S, :SW, :W]
            i = directions.index(@command)
            j = directions.index(unit.next_command)

            offset = lambda do |positions_clockwise|
              directions[(i + positions_clockwise) % 8]
            end

            unit.next_command = case((j-i) % 8)
            when 2 then offset.call(1) # ortho clockwise
            when 3 then offset.call(2) # diagonal away clockwise
            when 4 then nil # opposite
            when 5 then offset.call(-2) # diagonal away counter-clockwise
            when 6 then offset.call(-1) # ortho counter-clockwise
            else unit.next_command # shouldn't happen
            end
          end
        end
    end
  end
end