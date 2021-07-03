class MatchConfiguration < ApplicationRecord
  belongs_to :map, optional: true
  has_one :match
  has_one :challenge

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
    self.map ||= other.map || Map.random
    self.actions_per_turn ||= other.actions_per_turn || 1
    self.turn_progression ||= other.turn_progression
  end
end