require_relative './infantry'

class Sniper < Infantry
  def initialize square, **kwargs
    super
    @type = :sniper
  end

  def assignThreat
    super
    @square
      .neighbors(
        headings: [[0, 1], [1, 1]],
        repeat: Float::INFINITY,
        inclusive: true,
        rotate: true
      ) { |square| !square.terrain.obstructed? || square.empty? }
      .each do |square|
        if square.terrain.passable? && !threatens.include?(square.address.to_sym)
          threaten square
        end
      end
  end
end