class Terrain
  attr_reader :type, :category, :defense_modifier, :offense_modifier

  def initialize(category: nil, type: nil)
    case category&.to_sym&.downcase
    when :exposed
      @category = :exposed
      @type = type ? type.to_sym&.downcase : :road
      @defense_modifier = -1
      @offense_modifier = 0
      @passable = true
      @obstructs = false
    when :impassable
      @category = :impassable
      @type = type&.to_sym&.downcase || :mountain
      @defense_modifier = 0
      @offense_modifier = 0
      @passable = false
      @obstructs = true
    when :protected
      @category = :protected
      @type = type&.to_sym&.downcase || :forest
      @defense_modifier = 1
      @offense_modifier = 0
      @passable = true
      @obstructs = true
    else
      @category = :standard
      @type = type&.to_sym&.downcase || :plains
      @defense_modifier = 0
      @offense_modifier = 0
      @passable = true
      @obstructs = false
    end
  end

  def to_h
    {
      category: category,
      type: type,
      defense_modifier: defense_modifier,
      offense_modifier: offense_modifier,
      passable: passable?,
      obstructs: obstructs?
    }
  end

  def passable?
    @passable
  end

  def obstructs?
    @obstructs
  end
end