require_relative './infantry.rb'

class Sniper < Infantry
  def initialize square, team
    super
    @type = :sniper
  end

  def assignThreat
    super
    @square
      .neighbors(
        headings: [[0, 1], [1, 1]],
        repeat: Float::INFINITY,
        test: proc { |square| !square.obstructed? },
        inclusive: true
      )
      .each { |square| threaten square if square.passable?}
  end
end