require_relative './infantry.rb'

class Command < Infantry
  def initialize square, team
    super
    @type = :command
  end

  # +1 defense to orthogonally adjacent friendlies
  def after_move
    super
    @square
      .neighbors(headings:[[0, 1]], units: true)
      .each { |unit| unit.defense_modifier++ if unit.team == @team }
  end
end