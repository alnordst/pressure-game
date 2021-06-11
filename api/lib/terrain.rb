class Terrain
  attr_reader :type, :defense_modifier, :category, :passable?, :obstructs?

  def initialize type
    @type = type
    @defense_modifier, @category, @passable?, @obstructs?

  def self.create(category:, type:)
    case category
    when :standard then StandardTerrain.new type
    when :protected then ProtectedTerrain.new type
    when :exposed then ExposedTerrain.new type
    when :impassable then ImpassableTerrain.new type
    end
  end

  def to_h(slim?: false)
    def h = {
      category: category,
      type: type
    }
    h.merge!(
      defense_modifier: defense_modifier,
      passable: passable,
      obstructs: obstructs
    ) unless slim?
    return h
  end
end

class StandardTerrain < Terrain
  def initialize(type = 'plains')
    super
    @category = :standard
    @defenseModifier = 0
    @passable? = true
    @obstructs? = false
  end
end

class ProtectedTerrain < Terrain
  def initialize(type = 'forest')
    super
    @category = :protected
    @defense_modifier = 1
    @passable? = true
    @obstructs? = true
  end
end

class ExposedTerrain < Terrain
  def initialize(type = 'road')
    super
    @category = :exposed
    @defense_modifier = -1
    @passable? = true
    @obstructs? = false
  end
end

class ImpassableTerrain < Terrain
  def initialize(type = 'mountain')
    super
    @category = :exposed
    @passable? = false
    @obstructs? = true
  end
end