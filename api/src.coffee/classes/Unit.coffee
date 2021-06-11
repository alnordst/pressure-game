class Unit
  constructor: (@square, @team) ->
    @baseOffense, @baseDefense = 1
    @threatens, @validCommands = []
    @category, @type, @previousSquare, @command, @nextCommand

  @create: (square, {team, type}) ->
    switch type
      when 'artillery' then new Artillery square, team
      when 'command' then new Command square, team
      when 'infantry' then new BasicInfantry square, team
      when 'sniper' then new Sniper square, team
      when 'tank' then new Tank square, team

  serialize: (slim=false) ->
    essential =
      category: @category
      type: @type
      team: @team
      nextCommand: @nextCommand
    extra =
      previousSquare: @previousSquare
      command: @command
      threatens: @threatens
      validCommands: @validCommands
      offense: @offense()
      defense: @defense()
      isOvercome: @isOvercome()
      moved: @moved()
    if slim
      essential
    else
      { essential..., extra... }

  ## Statuses ##
  offense: () ->
    @baseOffense

  defense: () ->
    @baseDefense + @square.terrain.defenseModifier

  isOvercome: () ->
    opposition = if @team=='blue' then 'red' else 'blue'
    @defense() < @square.threat[opposition]

  moved: () ->
    @previousSquare? and @square != @previousSquare

  ## Basic Actions ##
  threaten: (square) ->
    @threatens.push square.heading
    square.threat[@team] += @offense()
    square.threatenedBy[@team].push @square.heading

  moveTo: (square) ->
    @previousSquare = @square
    @square.removeUnit this
    square.units.push this
    @square = square

  ## Lifecycle ##
  setCommand: (command) ->
    @command = command if @validCommands.includes command

  assignThreat: () ->

  beforeMove: () ->

  move: () ->
    if @command
      square = @square.getter
        direction: @command
      if square.terrain.isPassable
        @moveTo square
    @command = null
  
  afterMove: () ->

  rebound: () ->
    @square.removeUnit this
    @previousSquare.units.push this
    @square = @previousSquare
    @previousSquare = null


class Infantry extends Unit
  constructor: (square, team) ->
    super square, team
    @category = 'infantry'
    @validCommands = ['NW, N, NE, E, SE, S, SW, W, C']

  assignThreat: () ->
    squares = @square.getter
      headings: [[0,1],[1,1]]
    squares.forEach (square) ->
      @threaten square

  # infantry battle shift
  afterMove: () ->
    followers =
      N: [SE, S, SW]
      E: [SW, W, NW]
      S: [NW, N, NE]
      W: [NE, E, SE]
    if @command of followers
      squares = @previousSquare.getter
        direction: followers[@command]
      squares
        .filter (square) ->
          unit = square.getUnit()
          unit.category == 'infantry' && unit.team == @team
        .forEach (square) ->
          unit = square.getUnit()
          unless unit.nextCommand?
            unit.nextCommand = @command
          else
            # handle case of 2+ battleshift actions pulling one unit -- average out vectors
            directions = ['NW', 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W']
            i = directions.indexOf(@command)
            j = directions.indexOf(unit.nextCommand)
            unit.nextCommand = switch((j - i) %% 8)
              when 2 then directions[(i + 1) %% 8] # ortho clockwise
              when 3 then directions[(i + 2) %% 8] # diagonal away clockwise
              when 4 then null # opposite
              when 5 then directions[(i - 2) %% 8] # diagonal away counter-clockwise
              when 6 then directions[(i - 1) %% 8] # ortho counter-clockwise
              else unit.nextCommand # shouldn't happen


class BasicInfantry extends Infantry
  constructor: (square, team) ->
    super square, team
    @type = 'infantry'


class Command extends Infantry
  constructor: (square, team) ->
    super square, team
    @type = 'command'

  # +1 defense to ortho adjacent friendlies
  afterMove: () ->
    super()
    squares = @square.getter
      headings: [[0,1]]
    squares
      .filter (square) ->
        square.getUnit()?.team == @team
      .forEach (square) ->
        square.getUnit().baseDefense++


class Sniper extends Infantry
  constructor: (square, team) ->
    super square, team
    @type = 'sniper'

  assignThreat: () ->
    super()
    squares = @square.getter
      headings: [[0,1],[1,1]]
      repeat: Infinity
      test: (square) ->
        square.isEmpty() and not square.terrain.isObstructed
      inclusive: true
    squares.forEach (square) ->
      @threaten square if square.terrain.isPassable


class Vehicle extends Unit
  constructor: (square, team) ->
    super square, team
    @category = 'vehicle'
    @validCommands = ['N, E, S, W, C']

  # vehicles continue rolling
  move: () ->
    if @command
      square = @square.getter
        direction: @command
      if square.terrain.isPassable
        @moveTo square
      if square.terrain.isObstructed or not square.terrain.isPassable
        @command = null


class Artillery extends Vehicle
  constructor: (square, team) ->
    super square, team
    @type = 'artillery'

  assignThreat: () ->
    squares = @square.getter
      headings: [[0,2],[0,3],[1,2],[2,1]]
    squares.forEach (square) ->
      @threaten square


class Tank extends Vehicle
  constructor: (square, team) ->
    super square, team
    @type = 'tank'
    @baseOffense = 2
    @baseDefense = 2

  assignThreat: () ->
    squares = @square.getter
      headings: [[0,1],[1,1]]
    squares.forEach (square) ->
      @threaten square

    
module.exports = Unit