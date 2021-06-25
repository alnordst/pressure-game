class MatchConfiguration < ApplicationRecord
  belongs_to :map, optional: true
  has_one :match
  has_one :challenge

  attribute :actions_per_turn, :integer, default: 1

  def equivalent_to?(other)
    map == other.map &&
    actions_per_turn == other.actions_per_turn &&
    turn_progression == other.turn_progression
  end

  def satisfies?(other)
    (map.nil? || other.map.nil? || map == other.map) &&
    (actions_per_turn.nil? || other.actions_per_turn.nil? || actions_per_turn == other.actions_per_turn) &&
    turn_progression == other.turn_progression
  end

  def merge!(other)
    map ||= other.map
    actions_per_turn ||= other.actions_per_turn
    turn_progression ||= other.turn_progression
  end
end