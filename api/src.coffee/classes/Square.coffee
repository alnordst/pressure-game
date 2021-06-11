import Terrain from './Terrain'
import Unit from './Unit'

class Square
  constructor: (@heading, @getter, {terrain, unit}) ->
    @terrain = Terrain.create terrain
    @units = [Unit.create this, unit]
    @threat =
      red: 0
      blue: 0
    @threatenedBy =
      red: []
      blue: []

  ## Statuses ##
  isOccupied: -> @units.length
  isAlone: -> @units.length == 1
  isObstructed: -> @terrain.isObstructed || @isOccupied()

  getUnit: () ->
    @units[0] if @isAlone() else null

  removeUnit: (unit) ->
    @units = @units.filter (it) -> it != unit

  assignThreat: () ->
    @getUnit()?.assignThreat()

  getAvailableMoves: () ->
    if @isAlone()
      @availableMoves = @units[0].availableMoves()



  resolve: () ->
    if @units.any (unit) -> unit.team != units[0].team
      @units = @units.filter (unit) ->
        unit.defense >= @threat[unit.opposition()]
    if @units.length >= 2
      [temp, @units] = [@units, []]
      temp.forEach (unit) ->
        unit.previousSquare.units.push(unit)
        unit.square = unit.previousSquare
        unit.previousSquare.resolve()

  serialize: (slim=false) ->
    essential =
      terrain: @terrain.serialize
      unit: @units[0].serialize
    extra =
      availableMoves: @availableMoves
      threat: @threat
      threatenedBy: @threatenedBy
      isOccupied: @isOccupied()
      isPassable: @isPassable()
      isObstructed: @isObstructed()
    if slim
      essential
    else
      { essential..., extra... }

module.exports = Square