require_relative './vehicle.rb'

class Tank < Vehicle
  def initialize square, team
    super
    @type = :tank
    @baseOffense = 2
    @baseDefense = 2
  end

  def assign_threat
    super
    square
      .neighbors(headings: [[0, 1], [1, 1]])
      .each { |square| threaten square }
  end
end