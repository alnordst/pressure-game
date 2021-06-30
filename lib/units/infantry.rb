require_relative './unit'

class Infantry < Unit
  def initialize square, **kwargs
    super
    @category = :infantry
    @type = :infantry
    @valid_commands = [:NW, :N, :NE, :E, :SE, :S, :SW, :W, :C]
  end

  def assign_threat
    super
    threaten square
    square
      .neighbors(headings:[[0, 1], [1, 1]], rotate: true)
      .each { |other_square| threaten other_square }
  end

  def before_move
    super
    follower_directions = {
      N: [:E, :S, :W],
      E: [:S, :W, :N],
      S: [:W, :N, :E],
      W: [:N, :E, :S]
    }
    if follower_directions.has_key? command
      square
        .neighbors(headings: follower_directions[command], units: true)
        .filter { |unit| unit.category == :infantry && unit.team == team }
        .reject { |unit| unit.command }
        .each do |unit|
          unless unit.next_command
            unit.next_command = command
          else
            directions = [:NW, :N, :NE, :E, :SE, :S, :SW, :W]
            i = directions.index(command)
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