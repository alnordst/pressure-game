require_relative './vehicle.rb'

class Artillery < Vehicle
  def initialize square, team
    super
    @type = :artillery
  end

  def assign_threat
    super
    @square
      .neighbors(headings: [[0, 2], [0, 3], [1, 2], [2, 1]])
      .each { |square| threaten square }
  end
end