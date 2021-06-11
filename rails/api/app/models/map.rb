require 'board'

class Map < ApplicationRecord
  belongs_to :creator, :class_name => "Player"
  has_many :match_configurations
  has_many :matches, through: :match_configurations

  before_create do
    data = JSON.parse(json, symbolize_names: true)
    board = Board.new(data)
    throw 'game is over' unless board.loser.nil?
    board.cleanup
    board.cleanup
    self.json = board.to_json
    self.ranks = board.ranks
    self.files = board.files
  end

  def self.random
    offset = rand(count)
    Map.offset(offset).first
  end

  def board
    data = JSON.parse(json, symbolize_names: true)
    Board.new(data)
  end

  def self.board(json)
    data = JSON.parse(json, symbolize_names: true)
    Board.new(data)
  end

end