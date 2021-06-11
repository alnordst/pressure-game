class PlayerWebhook < ApplicationRecord
  belongs_to :player
  belongs_to :webhook
end
