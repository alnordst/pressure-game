class DrawOffer < ApplicationRecord
  belongs_to :player
  belongs_to :match
end
