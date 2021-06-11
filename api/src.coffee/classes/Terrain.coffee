class Terrain
  constructor: (@type) ->
    @defenseModifier, @category, @isPassable, @obstructs

  @create: ({category, type}) ->
    switch category
      when 'standard' then new StandardTerrain type
      when 'protected' then new ProtectedTerrain type
      when 'exposed' then new ExposedTerrain type
      when 'impassable' then new ImpassableTerrain type

  serialize: (slim=false) ->
    essential =
      category: @category
      type: @type
    extra =
      defenseModifier: @defenseModifier
      isPassable: @isPassable
      obstructs: @obstructs
    if slim
      essential
    else
      { essential..., extra... }


class StandardTerrain extends Terrain
  constructor: (type) ->
    super type
    @category = 'standard'
    @defenseModifier = 0
    @isPassable = true
    @obstructs = false


class ProtectedTerrain extends Terrain
  constructor: (type) ->
    super type
    @category = 'protected'
    @defenseModifier = 1
    @isPassable = true
    @obstructs = true

class ExposedTerrain extends Terrain
  constructor: (type) ->
    super type
    @category = 'exposed'
    @defenseModifier = -1
    @isPassable = true
    @obstructs = false

class ImpassableTerrain extends Terrain
  constructor: (type) ->
    super type
    @category = 'exposed'
    @isPassable = false
    @obstructs = true


module.exports = Terrain