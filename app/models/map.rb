require 'board'

class Map < ApplicationRecord
  belongs_to :creator, :class_name => "Player"
  has_many :match_configurations
  has_many :matches, through: :match_configurations

  before_create do
    parsed_data = JSON.parse(data, symbolize_names: true)
    board = Board.new(parsed_data)
    throw 'game is over' unless board.loser.nil?
    board.reset
    self.data = board.to_json
    self.ranks = board.ranks
    self.files = board.files
  end

  def self.random
    offset = rand(count)
    Map.offset(offset).first
  end

  # for testing
  def board
    data = JSON.parse(data, symbolize_names: true)
    Board.new(data)
  end

  # for testing
  def self.board(data)
    data = JSON.parse(data, symbolize_names: true)
    Board.new(data)
  end
end