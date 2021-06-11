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
      ) { |square| !square.obstructed? }
      .each { |square| threaten square if square.passable?}
  end
end