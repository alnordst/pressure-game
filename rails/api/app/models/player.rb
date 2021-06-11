class Player < ApplicationRecord
  has_many :player_webhooks, dependent: :destroy
  has_many :webhooks, through: :player_webhooks
  has_many :challenges, dependent: :destroy
  has_many :moves, dependent: :destroy
  has_many :maps, foreign_key: "creator"
  has_many :draw_offers, dependent: :destroy
  has_many :concessions, dependent: :destroy

  def matches
    Match.with_player(id)
  end
end
