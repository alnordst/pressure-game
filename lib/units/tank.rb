require_relative './vehicle'

class Tank < Vehicle
  def initialize square, **kwargs
    super
    @type = :tank
    @base_offense = 2
    @base_defense = 2
  end

  def assign_threat
    super
    square
      .neighbors(headings: [[0, 1], [1, 1]], rotate: true)
      .each { |square| threaten square }
  end
end