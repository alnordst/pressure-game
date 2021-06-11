class Team
  class << self
    def opposite(team)
      new(team)&.opposite
    end

    def red
      new :red
    end

    def blue
      new :blue
    end
  end

  def initialize(team)
    case team.to_sym.downcase
    when :red
      @team = :red
      @opposite = :blue
    when :blue
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

  def opposite
    Team.new @opposite
  end

  def ==(other)
    to_sym == other.to_sym
  end
end