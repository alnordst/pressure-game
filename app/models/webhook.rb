class Webhook < ApplicationRecord
  has_many :player_webhooks
  has_many :players, through: :player_webhooks
end
