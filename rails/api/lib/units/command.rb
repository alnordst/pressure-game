require_relative './infantry'

class Command < Infantry
  def initialize square, **kwargs
    super
    @type = :command
  end

  # +1 defense to orthogonally adjacent friendlies
  def assign_threat
    super
    @square
      .neighbors(headings:[[0, 1]], rotate: true, units: true)
      .each { |unit| unit.defense_modifier += 1 if unit.team == @team }
  end

  # take away defense modifier bonus before moving
  def before_move
    super
    @square
      .neighbors(headings:[[0, 1]], rotate: true, units: true)
      .each{ |unit| unit.defense_modifier -= 1 if unit.team == @team}
  end

  # give it back after move
  def after_move
    super
    @square
      .neighbors(headings:[[0, 1]], rotate: true, units: true)
      .each { |unit| unit.defense_modifier += 1 if unit.team == @team }
  end
end