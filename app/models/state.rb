class State < ApplicationRecord
  belongs_to :match
  has_many :moves
end
