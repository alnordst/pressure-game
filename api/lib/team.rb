class Team
  attr_reader :opposite

  class << self
    def opposite(team)
      new(team)&.opposite
    end
  end

  def initialize(team)
    if(team.to_sym == :red)
      @team = :red
      @opposite = :blue
    elsif(team.to_sym == :blue)
      @team = :blue
      @opposite = :red
    end
  end

  def to_sym
    @team.to_sym
  end

  def to_s
    @to_sym.to_s
  end
end