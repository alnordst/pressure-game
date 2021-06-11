class Challenge < ApplicationRecord
  belongs_to :player
  belongs_to :match_configuration
end
