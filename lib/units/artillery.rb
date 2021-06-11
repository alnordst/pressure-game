require_relative './vehicle'

class Artillery < Vehicle
  def initialize square, **kwargs
    super
    @type = :artillery
  end

  def assign_threat
    super
    @square
      .neighbors(headings: [[0, 2], [0, 3], [1, 2], [2, 1]], rotate: true)
      .each { |square| threaten square }
  end
end